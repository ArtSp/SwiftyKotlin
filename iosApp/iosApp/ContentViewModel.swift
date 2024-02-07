
import Foundation
import Shared

class ContentViewModel: ObservableObject {
    
    // TODO: DI
    private let fakeVersionUseCase = VersionUseCase(client: FakeVersionClient())
    private let beVersionUseCase = VersionUseCase(client: KtorVersionClient())
    
    @Published var error: String?
    @Published var appVersion: String?
    @Published var beVersion: String?
    @Published var useFake: Bool = true {
        didSet {
            appVersion = nil
            beVersion = nil
            loadAppVersion()
        }
    }
    
    init() {
        loadAppVersion()
    }
    
    private var versionUseCase: VersionUseCase {
        useFake ? fakeVersionUseCase : beVersionUseCase
    }
    
    func loadAppVersion() {
        let version = versionUseCase.getAppVersion()
        appVersion = [version.platform, version.version].joined(separator: " ")
    }

    func loadBEVersion() {
        Task { @MainActor in
            do {
                let version = try await versionUseCase.getServerVersion()
                beVersion = [version.platform, version.version].joined(separator: " ")
            } catch {
                // TODO: Extract just error message
                self.error = error.localizedDescription
            }
        }
    }
    
}
