import Foundation

struct VocabularyItem: Identifiable, Codable, Hashable {
    let english: String
    let french: String
    var id: String { english + french }
}

struct Course: Codable {
    var title = "Cours médical"
    var date = Date()
    var transcript = ""
    var translation = ""
    var vocabulary: [VocabularyItem] = []
}

enum MedTranslateError: LocalizedError {
    case missingKey, recordingFailed, invalidResponse, api(String)
    var errorDescription: String? {
        switch self {
        case .missingKey: return "Ajoutez votre clé API OpenAI dans Réglages."
        case .recordingFailed: return "Impossible d'enregistrer le microphone. Vérifiez son autorisation dans les réglages macOS."
        case .invalidResponse: return "Réponse du service impossible à lire."
        case .api(let message): return message
        }
    }
}
