
import MPSwiftUI

struct LoginView: LocalizedView {
    
    @StateObject var viewModel: LoginViewModel = .init()
    @Environment(\.navigationRouter) private var router
    
    var body: some View {
        VStack {
            TextField(localizedKey("username"), text: $viewModel.username)
            SecureField(localizedKey("password"), text: $viewModel.password)
            Button(localizedKey("login")) {
                viewModel.login(username: viewModel.username, password: viewModel.password)
            }
        }
        .padding()
        .handleAlert(item: $viewModel.alert)
        .onReceive(viewModel.navigation) { router?.path.append($0) }
    }
    
}

#Preview {
    LoginNavigation {
        LoginView()
    }
}
