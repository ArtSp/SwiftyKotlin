import Foundation
import Shared
import Combine
import KMPNativeCoroutinesAsync

class ChatViewModel: ObservableObject {
    
    @Published var serverDate: ServerDate?
    @Published var isLoading: Set<Content> = .init()
    @Published var error: AppError?
    @Published var message: String = ""
    @Published var messages: [ChatMessage] = []
    
    private let chatUseCase: ChatUseCase
    private var asyncServerTimeFlowHandle: Task<Void, Error>?
    private var asyncChatFlowHandle: Task<Void, Error>?
    private var typingCancelable: AnyCancellable?
    
    init(chatUseCase: ChatUseCase) {
        self.chatUseCase = chatUseCase
        connect()
    }
    
    var sendDisabled: Bool { message.isEmpty }
    
    func sendMessage() {
        guard !message.isEmpty else { return }
        
        Task { @MainActor in
            isLoading.insert(.sendMessage); defer { isLoading.remove(.sendMessage) }
            do {
                _ = try await asyncFunction(for: chatUseCase.sendMessage(text: message))
                message.removeAll()
            } catch {
                self.error = error.appError
            }
        }
    }
    
    private func connect() {
        getBackendDateAsync()
        establishChatConnection()
    }
    
    private func establishChatConnection() {
        asyncChatFlowHandle?.cancel()
        asyncChatFlowHandle = Task { @MainActor in
            isLoading.insert(.chat); defer { isLoading.remove(.chat) }
            do {
                for try await element in asyncSequence(for: chatUseCase.establishChatConnection()) {
                    messages = element
                }
            } catch {
                self.error = error.appError
            }
        }
    }
    
    private func getBackendDateAsync() {
        serverDate = nil
        asyncServerTimeFlowHandle?.cancel()
        asyncServerTimeFlowHandle = Task { @MainActor in
            isLoading.insert(.serverDate); defer { isLoading.remove(.serverDate) }
            do {
                for try await element in asyncSequence(for: chatUseCase.getServerDate()) {
                    serverDate = element
                }
            } catch {
                self.error = error.appError
            }
        }
    }
    
}

extension ChatViewModel {
    enum Content: Hashable {
        case serverDate, chat, sendMessage
    }
}
