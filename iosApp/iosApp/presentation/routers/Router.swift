
import MPSwiftUI

enum Router {
    static let common = NavigationRouter()
    static let main = NavigationRouter()
    static let login = NavigationRouter()
    
    static var allCases: [NavigationRouter] {
        [
            common,
            main,
            login,
        ]
    }

    static func popToRoot() {
        allCases.forEach { $0.popToRoot() }
    }

}
