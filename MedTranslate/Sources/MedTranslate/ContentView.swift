import SwiftUI
import Translation

struct ContentView: View {
    @EnvironmentObject private var store: CourseStore
    @State private var translationConfiguration: TranslationSession.Configuration?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            HSplitView {
                transcriptPanel
                translationPanel
            }
            Divider()
            vocabularyPanel
        }
        .alert("MedTranslate", isPresented: Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })) {
            Button("OK", role: .cancel) { store.errorMessage = nil }
        } message: { Text(store.errorMessage ?? "") }
        .onChange(of: store.course.transcript) { _, transcript in
            guard !transcript.isEmpty else { return }
            translationConfiguration = TranslationSession.Configuration(
                source: Locale.Language(identifier: "en"),
                target: Locale.Language(identifier: "fr")
            )
        }
        .translationTask(translationConfiguration) { session in
            do {
                let response = try await session.translate(store.course.transcript)
                store.course.translation = response.targetText
            } catch {
                store.course.translation = "La traduction Apple doit être téléchargée ou activée dans Réglages Système → Général → Langue et région → Langues de traduction."
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "stethoscope").font(.system(size: 30, weight: .semibold)).foregroundStyle(.teal)
            VStack(alignment: .leading) { Text("MedTranslate").font(.title2.bold()); Text("Anglais médical → français rigoureux").foregroundStyle(.secondary) }
            Spacer()
            TextField("Titre du cours", text: $store.course.title).textFieldStyle(.roundedBorder).frame(width: 220)
            Button(store.recorder.isRecording ? "Arrêter et transcrire" : "Démarrer l’enregistrement") { store.toggleRecording() }
                .buttonStyle(.borderedProminent).tint(store.recorder.isRecording ? .red : .teal).disabled(store.isWorking)
            if store.isWorking { ProgressView().controlSize(.small) }
            Button("Exporter") { store.exportCourse() }.disabled(store.course.transcript.isEmpty)
        }.padding()
    }

    private var transcriptPanel: some View { panel(title: "Transcription anglaise", symbol: "waveform") { TextEditor(text: $store.course.transcript).font(.body).padding(6) } }
    private var translationPanel: some View { panel(title: "Traduction médicale française", symbol: "cross.case") { TextEditor(text: $store.course.translation).font(.body).padding(6) } }
    private var vocabularyPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Vocabulaire médical EN → FR", systemImage: "books.vertical").font(.headline)
            Table(store.course.vocabulary) { TableColumn("Anglais") { Text($0.english) }; TableColumn("Français") { Text($0.french) } }
        }.padding().frame(minHeight: 160)
    }
    private func panel<Content: View>(title: String, symbol: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) { Label(title, systemImage: symbol).font(.headline); content() }.padding().frame(minWidth: 350, maxWidth: .infinity, maxHeight: .infinity)
    }
}
