import SwiftUI

@main
struct MedTranslateApp: App {
    @StateObject private var store = CourseStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 900, minHeight: 620)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Exporter le cours…") { store.exportCourse() }
                    .keyboardShortcut("e", modifiers: [.command])
                    .disabled(store.course.transcript.isEmpty)
            }
        }
    }
}
