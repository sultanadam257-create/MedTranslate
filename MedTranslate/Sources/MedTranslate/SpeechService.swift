import Foundation
import Speech

enum SpeechService {
    static func transcribe(audioURL: URL) async throws -> String {
        let authorization = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
        guard authorization == .authorized else {
            throw MedTranslateError.api("Autorisez la reconnaissance vocale dans Réglages Système → Confidentialité et sécurité → Reconnaissance vocale.")
        }
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US")), recognizer.isAvailable else {
            throw MedTranslateError.api("La reconnaissance vocale anglaise n’est pas disponible sur ce Mac.")
        }
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false
        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                } else if let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum MedicalGlossary {
    private static let entries: [VocabularyItem] = [
        .init(english: "blood pressure", french: "pression artérielle"),
        .init(english: "heart rate", french: "fréquence cardiaque"),
        .init(english: "diagnosis", french: "diagnostic"),
        .init(english: "treatment", french: "traitement"),
        .init(english: "symptom", french: "symptôme"),
        .init(english: "kidney", french: "rein"),
        .init(english: "liver", french: "foie"),
        .init(english: "inflammation", french: "inflammation"),
        .init(english: "infection", french: "infection"),
        .init(english: "dose", french: "dose")
    ]

    static func items(in text: String) -> [VocabularyItem] {
        let lowered = text.lowercased()
        return entries.filter { lowered.contains($0.english) }
    }
}
