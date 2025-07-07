import Foundation
import Combine
import FoundationModels

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

@MainActor
class ChatGameViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = [
        ChatMessage(text: "신호를 발견했다. 생존자가 있으면 회신하라.", isUser: false)
    ]
    @Published var isLoading: Bool = false

    private let session = LanguageModelSession()
    private var currentTask: Task<Void, Never>?

    func sendUserMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(ChatMessage(text: trimmed, isUser: true))
        askModel(prompt: trimmed)
    }

    func askModel(prompt: String) {
        currentTask?.cancel()
        isLoading = true
        currentTask = Task {
            do {
                var response = ""
                for try await chunk in session.streamResponse(to: prompt) {
                    if Task.isCancelled { return }
                    response = chunk
                    if let last = messages.last, !last.isUser {
                        messages[messages.count-1] = ChatMessage(text: response, isUser: false)
                    } else {
                        messages.append(ChatMessage(text: response, isUser: false))
                    }
                }
            } catch {
                if !Task.isCancelled {
                    messages.append(ChatMessage(text: "오류: \(error.localizedDescription)", isUser: false))
                }
            }
            if !Task.isCancelled { isLoading = false }
        }
    }

    deinit { currentTask?.cancel() }
} 