import Foundation

struct DayMessage: Identifiable {
    let id = UUID()
    let day: Int
    let content: String
}

struct PlayerResponse: Identifiable {
    let id = UUID()
    let day: Int
    let text: String
    let sentiment: SentimentResult?
    let intent: IntentResult?
    let keywords: [String]
}

struct SystemLog: Identifiable {
    let id = UUID()
    let day: Int
    let content: String
    let type: LogType
    enum LogType { case info, warning, danger }
}

struct SentimentResult {
    let label: String // "공포", "희망" 등
    let score: Double
}
struct IntentResult {
    let label: String // "구조 요청", "회피" 등
    let score: Double
} 