
import Foundation
import Combine

protocol Screen {
    associatedtype Destination
    associatedtype LoadingContent: Hashable
}

class ScreenViewModel<View: Screen>: ViewModel {
    
    @Published var alert: AlertInfo?
    @Published var isLoading: Set<View.LoadingContent> = .init()
    let navigation = PassthroughSubject<View.Destination, Never>()
}

class ViewModel: ObservableObject, LoggedInstance, CancelableStore {
    
    static var loggerCategory: LoggerCategory { .viewModel }
    
    @Injected(\.authUseCase) var authUseCase
    @Injected(\.chatUseCase) var chatUseCase
    @Injected(\.appUseCase) var appUseCase
   
    var appState: AppState { authUseCase.appState }
}
