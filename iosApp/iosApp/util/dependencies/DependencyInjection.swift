
import Foundation
import os
import Shared

extension AppDelegate {

    func assembleDependencies() {
        
        let preset: DependencyInjectionPreset

        #if DEBUG
        if ProcessInfo.processInfo.isRunningForPreviews {
            preset = .mock
        } else {
            preset = .mock
        }
        #else
        preset = .default
        #endif
        
        DependencyInjection.assemble(preset)
        
        Logger
            .app(category: .dependencyInjection)
            .debug("Preset `\(String(describing: preset))` assembled")
    }
}

enum DependencyInjectionPreset {
    case `default`
    case mock
    
    func dependencies() -> DependencyInjection {
        switch self {
        case .default:
            implementation()
            
        case .mock:
            mock()
        }
    }
    
    private func mock() -> DependencyInjection {
        let client = FakeRemoteClient()
        let localStorage = FakeLocalStorage()
        return DependencyInjection(
            authUseCase: AuthUseCase(client: client, localStorage: localStorage),
            chatUseCase: ChatUseCase(client: client),
            appUseCase: AppUseCase(client: client, localStorage: localStorage)
        )
    }
    
    private func implementation() -> DependencyInjection {
        let client = KtorRemoteClient()
        let localStorage = NativeLocalStorage()
        
        return DependencyInjection(
            authUseCase: AuthUseCase(client: client, localStorage: localStorage),
            chatUseCase: ChatUseCase(client: client),
            appUseCase: AppUseCase(client: client, localStorage: localStorage)
        )
    }
}

final class DependencyInjection {
    var authUseCase: AuthUseCase
    var chatUseCase: ChatUseCase
    var appUseCase: AppUseCase
    
    convenience private init(preset: DependencyInjectionPreset) {
        let dependencies = preset.dependencies()

        self.init(
            authUseCase: dependencies.authUseCase,
            chatUseCase: dependencies.chatUseCase,
            appUseCase: dependencies.appUseCase
        )
    }
    
    init(
        authUseCase: AuthUseCase,
        chatUseCase: ChatUseCase,
        appUseCase: AppUseCase
    ) {
        self.authUseCase = authUseCase
        self.chatUseCase = chatUseCase
        self.appUseCase = appUseCase
    }
    
    static func assemble(_ preset: DependencyInjectionPreset) {
        assembly = .init(preset: preset)
    }
    
    static var assembly: DependencyInjection = {
        .init(preset: ProcessInfo.processInfo.isRunningForPreviews ? .mock : .default)
    }()
}
