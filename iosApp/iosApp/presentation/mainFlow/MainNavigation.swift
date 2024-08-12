
import MPSwiftUI

struct MainNavigation<V: View>: View {
    
    private var router: NavigationRouter
    private var root: () -> V
    
    init(@ViewBuilder root: @escaping () -> V) {
        self.root = root
        self.router = Router.main
    }
    
    private init(router: NavigationRouter, @ViewBuilder root: @escaping () -> V) {
        self.root = root
        self.router = router
    }
    
    @ViewBuilder
    func destinationBody<Destination: View>(
        style: DestinationStyle,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        switch style {
        case .fullScreen, .sheet:
            MainNavigation<Destination>(router: .init()) { destination() }
            
        case .navigation:
            destination()
        }
    }
    
    var body: some View {
        AppNavigation(router: router) {
            root()
                .destination(for: MainView.Destination.self) { destination, style in
                    destinationBody(style: style) {
                        switch destination {
                        case let .chat(userName):
                            ChatView(viewModel: ChatViewModel(userName: userName))
                        }
                    }
                }
                
        }
    }
}
