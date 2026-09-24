import Foundation

struct OpenAIService {
    let apiKey: String

    func transcribe(audioURL: URL) async throws -> String {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        func append(_ value: String) { body.append(value.data(using: .utf8)!) }
        append("--\(boundary)\r\nContent-Disposition: form-data; name=\"model\"\r\n\r\ngpt-transcribe\r\n")
        append("--\(boundary)\r\nContent-Disposition: form-data; name=\"languages[]\"\r\n\r\nen\r\n")
        append("--\(boundary)\r\nContent-Disposition: form-data; name=\"prompt\"\r\n\r\nMedical lecture in English. Preserve medical terminology, drug names, anatomy, abbreviations and numbers exactly.\r\n")
        append("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"lecture.m4a\"\r\nContent-Type: audio/mp4\r\n\r\n")
        body.append(try Data(contentsOf: audioURL))
        append("\r\n--\(boundary)--\r\n")
        request.httpBody = body
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data)
        struct Transcription: Decodable { let text: String }
        guard let result = try? JSONDecoder().decode(Transcription.self, from: data) else { throw MedTranslateError.invalidResponse }
        return result.text
    }

    func translate(_ transcript: String) async throws -> (String, [VocabularyItem]) {
        let prompt = """
        Translate this English medical lecture into rigorous French medical language. Do not summarize, omit, reinterpret, or add facts. Preserve uncertainty, measurements, drug names, abbreviations, and anatomy precisely. Return ONLY valid JSON with keys translation (string) and vocabulary (array of at most 30 objects, each with english and french). Include only medically relevant terms in vocabulary.

        LECTURE:
        \(transcript)
        """
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = ["model": "gpt-5-mini", "input": prompt]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response, data)
        let root = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let output = root?["output"] as? [[String: Any]] ?? []
        let content = output.flatMap { $0["content"] as? [[String: Any]] ?? [] }
        guard let jsonText = content.compactMap({ $0["text"] as? String }).first,
              let jsonData = jsonText.data(using: .utf8) else { throw MedTranslateError.invalidResponse }
        struct Result: Decodable { let translation: String; let vocabulary: [VocabularyItem] }
        let result = try JSONDecoder().decode(Result.self, from: jsonData)
        return (result.translation, result.vocabulary)
    }

    private func validate(_ response: URLResponse, _ data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw MedTranslateError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            let detail = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"] as? [String: Any]
            throw MedTranslateError.api(detail?["message"] as? String ?? "Le service OpenAI a renvoyé l’erreur \(http.statusCode).")
        }
    }
}
