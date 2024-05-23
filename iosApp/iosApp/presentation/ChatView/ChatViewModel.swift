import Foundation
import Shared
import KMPNativeCoroutinesAsync

class ChatViewModel: ObservableObject {
    
    private var asyncServerTimeFlowHandle: Task<Void, Error>?
    
    @Published var serverDate: ServerDate?
    @Published var isLoading: Set<Content> = .init()
    @Published var error: AppError?
    
    let chatUseCase: ChatUseCase
    
    init(chatUseCase: ChatUseCase) {
        self.chatUseCase = chatUseCase
        connect()
    }
    
}

private extension ChatViewModel {
    
    func connect() {
        getBackendDateAsync()
    }
    
    func getBackendDateAsync() {
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
        case serverDate, chat
    }
}
