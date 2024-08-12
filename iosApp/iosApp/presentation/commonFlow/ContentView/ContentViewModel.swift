
import Foundation

extension ContentView: Screen {
    
    enum Content {
        case login
        case main
    }
    
    enum Destination {
        case update
    }
    
    typealias LoadingContent = Never
}

class ContentViewModel: ScreenViewModel<ContentView> {
    
    @Published var presented: ContentView.Content?
    @Published var updateRequired = false
    
    static var shared = ContentViewModel()
    
    override init() {
        super.init()
        
        if appState.authStatus.isLoggedIn {
            presented = .main
        } else {
            presented = .login
        }
        
        NotificationCenter.default
            .publisher(for: AppNotification.authorized)
            .sinkValue { _ in
                Router.popToRoot()
                self.presented = .main
            }
            .store(in: &cancelables)
    }
    
    func logout() {
        Router.popToRoot()
        authUseCase.logout()
        presented = .login
    }
    
    func checkForUpdates() {
        Task { @MainActor in
            let update = try? await asyncFunction(for: appUseCase.checkForUpdates())
            updateRequired = update?.isReqired == true
            if updateRequired { navigation.send(.update) }
        }
         
    }
    
}
