
import MPSwiftUI

struct AppNavigation<Content: View>: View {
    
    @ObservedObject var router: NavigationRouter = .init()
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        NavigationStack(path: $router.path) {
            content()
//                .handleDeeplinkDestinations()
//                .configureNavigationController { uiNavController in
//                    // Back Button
//                    let backItemAppearance = UIBarButtonItemAppearance()
//                    backItemAppearance.normal.titleTextAttributes = [
//                        .font: UIFont(name: "Inter-Regular_Medium", size: 16)!
//                    ]
//
//                    // Standard Appearance
//                    let standardAppearance = UINavigationBarAppearance()
//                    standardAppearance.configureWithDefaultBackground()
//                    standardAppearance.backButtonAppearance = backItemAppearance
//                    standardAppearance.titleTextAttributes = [
//                        .font: UIFont(name: "Oswald-Regular_Medium", size: 16)!
//                    ]
//                    standardAppearance.largeTitleTextAttributes = [
//                        .font: UIFont(name: "Oswald-Regular_Medium", size: 24)!
//                    ]
//
//                    uiNavController.navigationBar.standardAppearance = standardAppearance
//
//                    // Scroll Edge Appearance Appearance
//                    let scrollEdgeAppearance = UINavigationBarAppearance()
//                    scrollEdgeAppearance.configureWithTransparentBackground()
//                    scrollEdgeAppearance.backButtonAppearance = backItemAppearance
//                    scrollEdgeAppearance.titleTextAttributes = [
//                        .font: UIFont(name: "Oswald-Regular_Medium", size: 16)!
//                    ]
//                    scrollEdgeAppearance.largeTitleTextAttributes = [
//                        .font: UIFont(name: "Oswald-Regular_Medium", size: 24)!
//                    ]
//                    uiNavController.navigationBar.scrollEdgeAppearance = scrollEdgeAppearance
//                }
        }
        .environment(\.navigationRouter, router)
    }
}
