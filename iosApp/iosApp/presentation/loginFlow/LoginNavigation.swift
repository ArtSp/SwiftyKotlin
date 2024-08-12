
import MPSwiftUI

struct LoginNavigation<V: View>: View {
    
    private var router: NavigationRouter
    private var root: () -> V
    
    init(@ViewBuilder root: @escaping () -> V) {
        self.root = root
        self.router = Router.login
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
            LoginNavigation<Destination>(router: .init()) { destination() }
            
        case .navigation:
            destination()
        }
    }
    
    var body: some View {
        AppNavigation(router: router) {
            root()
        }
    }
}
