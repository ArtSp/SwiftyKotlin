
import MPSwiftUI

struct ContentView: LocalizedView {
    
    @ObservedObject var viewModel = ContentViewModel.shared
    @Environment(\.fullScreenOpen) private var router
    
    var body: some View {
        Group {
            if let presented = viewModel.presented {
                makeContentView(screen: presented)
                    .environment(\.updateRequired, viewModel.updateRequired)
            } else {
                makeSplashView()
            }
        }
        .onReceive(viewModel.navigation) { router?(show: $0) }
        .onAppear { viewModel.checkForUpdates() }
        .destination(for: Destination.self) { destination, style in
            switch destination {
            case .update:
                CommonNavigation {
                    UpdateView()
                }
            }
        }
    }
    
    @ViewBuilder
    func makeContentView(screen: Content) -> some View {
        switch screen {
        case .main:
            MainNavigation {
                MainView()
            }
            
        case .login:
            LoginNavigation {
                LoginView()
            }
        }
    }
    
    func makeSplashView() -> some View {
        Color.white
    }
}

#Preview {
    ContentView()
}
