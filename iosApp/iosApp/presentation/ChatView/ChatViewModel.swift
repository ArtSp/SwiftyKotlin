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
    @Published var connectedUsers: Int = 0
    
    private let userName: String
    private let chatUseCase: ChatUseCase
    private var asyncServerTimeFlowHandle: Task<Void, Error>?
    private var asyncChatFlowHandle: Task<Void, Error>?
    private var asyncChatConnectionsHandle: Task<Void, Error>?
    private var typingCancelable: AnyCancellable?
    
    init(
        userName: String,
        chatUseCase: ChatUseCase
    ) {
        self.userName = userName
        self.chatUseCase = chatUseCase
        connect()
    }
    
    var sendDisabled: Bool { message.isEmpty || connectedUsers < 1 }
    
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
        listenActiveConnections()
    }
    
    private func establishChatConnection() {
        asyncChatFlowHandle?.cancel()
        asyncChatFlowHandle = Task { @MainActor in
            isLoading.insert(.chat); defer { isLoading.remove(.chat) }
            do {
                for try await element in asyncSequence(for: chatUseCase.establishChatConnection(userName: userName)) {
                    messages = element
                }
            } catch {
                self.error = error.appError
            }
        }
    }

    private func listenActiveConnections() {
        asyncChatConnectionsHandle?.cancel()
        asyncChatConnectionsHandle = Task { @MainActor in
            do {
                for try await element in asyncSequence(for: chatUseCase.connectionsFlow) {
                    connectedUsers = element.intValue
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
