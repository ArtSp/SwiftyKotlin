
import MPSwiftUI
import Combine

extension UpdateView: Screen {
    typealias Destination = Never
    typealias LoadingContent = Never
}

final class UpdateViewModel: ScreenViewModel<UpdateView> {
    
    func update() {
        if let url = URL(string: appState.update?.url ?? "https://www.apple.com/app-store/") {
            UIApplication.shared.open(url)
        }
    }
}
