import SwiftUI
import UniformTypeIdentifiers
import AppKit

@MainActor
final class CourseStore: ObservableObject {
    @Published var course = Course()
    @Published var isWorking = false
    @Published var errorMessage: String?
    let recorder = AudioRecorder()

    func toggleRecording() {
        Task {
            do {
                if recorder.isRecording { await finishRecording() } else { try await recorder.start() }
            } catch { errorMessage = error.localizedDescription }
        }
    }

    private func finishRecording() async {
        guard let audio = recorder.stop() else { return }
        guard let key = Keychain.read(), !key.isEmpty else { errorMessage = MedTranslateError.missingKey.localizedDescription; return }
        isWorking = true
        defer { isWorking = false }
        do {
            let service = OpenAIService(apiKey: key)
            let transcript = try await service.transcribe(audioURL: audio)
            let result = try await service.translate(transcript)
            course.transcript = transcript
            course.translation = result.0
            course.vocabulary = result.1
            course.date = Date()
        } catch { errorMessage = error.localizedDescription }
    }

    func exportCourse() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(course.title.replacingOccurrences(of: " ", with: "-"))\.md"
        panel.allowedContentTypes = [.plainText]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let vocabulary = course.vocabulary.map { "- **\($0.english)** → \($0.french)" }.joined(separator: "\n")
        let markdown = "# \(course.title)\n\n\(course.date.formatted())\n\n## Transcription anglaise\n\n\(course.transcript)\n\n## Traduction médicale française\n\n\(course.translation)\n\n## Vocabulaire\n\n\(vocabulary)\n"
        try? markdown.write(to: url, atomically: true, encoding: .utf8)
    }
}
