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
    @Published var remoteIsTyping: Bool = false
    
    private let userName: String
    private let chatUseCase: ChatUseCase
    private var asyncHandles: [AsyncTask: Task<Void, Error>] = [:]
    
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
    
    func sendIsTyping() {
        guard !message.isEmpty else { return }
        chatUseCase.sendIsTyping()
    }

    private func connect() {
        getBackendDateAsync()
        establishChatConnection()
        listenActiveConnections()
        listenIsTyping()
    }
    
    private func establishChatConnection() {
        asyncHandles[.chat]?.cancel()
        asyncHandles[.chat] = Task { @MainActor in
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
        asyncHandles[.chatConnections]?.cancel()
        asyncHandles[.chatConnections] = Task { @MainActor in
            do {
                for try await element in asyncSequence(for: chatUseCase.connectionsFlow) {
                    connectedUsers = element.intValue
                }
            } catch {
                self.error = error.appError
            }
        }
    }

    private func listenIsTyping() {
        asyncHandles[.chatTyping]?.cancel()
        asyncHandles[.chatTyping] = Task { @MainActor in
            do {
                for try await element in asyncSequence(for: chatUseCase.remoteIsTypingFlow) {
                    remoteIsTyping = element.boolValue
                }
            } catch {
                self.error = error.appError
            }
        }
    }
    
    private func getBackendDateAsync() {
        serverDate = nil
        asyncHandles[.serverTime]?.cancel()
        asyncHandles[.serverTime] = Task { @MainActor in
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

    private enum AsyncTask: Hashable {
        case serverTime, chat, chatConnections, chatTyping
    }
    enum Content: Hashable {
        case serverDate, chat, sendMessage
    }
}
