
import Foundation
import Shared

class ContentViewModel: ObservableObject {
    
    @Published var appVersion: String?
    @Published var beVersion: String?
    
    // TODO: DI
    let versionUseCase = VersionUseCase(client: FakeVersionClient())
    
    init() {
        loadAppVersion()
    }
    
    func loadAppVersion() {
        let version = versionUseCase.getAppVersion()
        appVersion = [version.platform, version.version].joined(separator: " ")
    }

    func loadBEVersion() {
        Task { @MainActor in
            let version = try await versionUseCase.getServerVersion()
            beVersion = [version.platform, version.version].joined(separator: " ")
        }
    }
    
}
