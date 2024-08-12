
import Foundation
import Combine

extension LoginView: Screen {
    enum Destination: Hashable {
        case createPin
    }
    
    enum LoadingContent: Hashable {
        case login
    }
}

final class LoginViewModel: ScreenViewModel<LoginView> {

    @Published var username: String = ""
    @Published var password: String = ""
    
    private var loginTask: Task<Void, Error>?
    
    func login(username: String, password: String) {
        loginTask?.cancel()
        loginTask = Task { @MainActor in
            isLoading.insert(.login)
            defer { isLoading.remove(.login) }
            do {
                try await asyncFunction(for: authUseCase.login(username: username, password: password))
            } catch {
                self.alert = error.alertInfo
            }
        }
    }
}
