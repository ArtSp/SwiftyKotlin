
import Foundation
import Combine

extension ChatView: Screen {
    typealias Destination = Never
    
    enum LoadingContent: Hashable {
        case serverDate, chat, sendMessage
    }
}

private extension ChatViewModel {

     enum AsyncTask: Hashable {
        case serverTime, chat, chatConnections, chatTyping
    }
    
}

class ChatViewModel: ScreenViewModel<ChatView> {
    
    @Published var serverDate: ServerDate?
    @Published var message: String = ""
    @Published var messages: [ChatMessage] = []
    @Published var connectedUsers: Int = 0
    @Published var remoteIsTyping: Bool = false
    
    private let userName: String
    private var asyncHandles: [AsyncTask: Task<Void, Error>] = [:]
    
    init(userName: String) {
        self.userName = userName
        super.init()
        
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
                self.alert = error.alertInfo
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
                self.alert = error.alertInfo
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
                self.alert = error.alertInfo
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
                self.alert = error.alertInfo
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
                self.alert = error.alertInfo
            }
        }
    }
    
}
