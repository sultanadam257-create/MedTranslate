import AVFoundation

@MainActor
final class AudioRecorder: NSObject, ObservableObject {
    @Published private(set) var isRecording = false
    private var recorder: AVAudioRecorder?
    private(set) var fileURL: URL?

    func start() async throws {
        let allowed = await AVCaptureDevice.requestAccess(for: .audio)
        guard allowed else { throw MedTranslateError.recordingFailed }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("medtranslate-\(UUID().uuidString).m4a")
        let settings: [String: Any] = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 44_100, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        fileURL = url
        isRecording = true
    }

    func stop() -> URL? {
        recorder?.stop()
        recorder = nil
        isRecording = false
        return fileURL
    }
}
