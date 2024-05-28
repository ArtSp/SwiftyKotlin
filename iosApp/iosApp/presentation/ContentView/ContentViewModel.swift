import Foundation
import Shared
import KMPNativeCoroutinesAsync

class ContentViewModel: ObservableObject {
    
    @Published var isLoading: Set<Content> = .init()
    @Published var error: AppError?
    @Published var appVersion: String?
    @Published var beVersion: String?
    @Published var clock: String?
    @Published var counter: Int = 0
    @Published var useFake: Bool = true {
        didSet {
            appVersion = nil
            beVersion = nil
            loadInitialData()
        }
    }
    
    private let fakeVersionUseCase = VersionUseCase(client: FakeRemoteClient())
    private let beVersionUseCase = VersionUseCase(client: KtorRemoteClient())
    private var asyncTimeFlowHandle: Task<Void, Error>?
    private var getBackendVersionTask: Task<Void, Error>?
    
    init() {
        loadInitialData()
    }
    
    var clockIsRunning: Bool { isLoading.contains(.timer) }
    var isLoadingRemoteVersion: Bool { isLoading.contains(.beVersion) }
    var chatUseCase: ChatUseCase { ChatUseCase(client: useFake ? FakeRemoteClient() : KtorRemoteClient()) }
    
    private var versionUseCase: VersionUseCase {
        // TODO: implement DI
        useFake ? fakeVersionUseCase : beVersionUseCase
    }
    
    func loadInitialData() {
        loadLocalVersion()
    }
    
    func loadLocalVersion() {
        let version = versionUseCase.getAppVersion()
        appVersion = "Platform: \(version.platform), App version: \(version.version)"
    }
    
    func loadRemoteVersion() {
        getBackendVersionAsync()
    }
    
    func toggleTimer() {
        if clockIsRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    // Use asyncFunction to create cancelable async call.
    // Without asyncFunction function will work async way but with no cancelation support.
    private func getBackendVersionAsync() {
        getBackendVersionTask?.cancel()
        getBackendVersionTask = Task { @MainActor in
            isLoading.insert(.beVersion); defer { isLoading.remove(.beVersion) }
            do {
                let version = try await asyncFunction(for: versionUseCase.getServerVersion())
                beVersion = [version.platform, version.version].joined(separator: " ")
            } catch {
                self.error = error.appError
            }
        }
    }
    
    // Use asyncSequence to create cancelable async sequence call.
    // Without asyncSequence function will work in closure way, with no cancelation support.
    private func startTimer() {
        stopTimer()
        asyncTimeFlowHandle?.cancel()
        asyncTimeFlowHandle = Task { @MainActor in
            isLoading.insert(.timer); defer { isLoading.remove(.timer) }
            do {
                for try await element in asyncSequence(for: versionUseCase.timeFlow()) {
                    clock = element
                }
            } catch {
                self.error = error.appError
            }
        }
    }
    
    // To cancel sequence, apply standard async/await approach
    private func stopTimer() {
        asyncTimeFlowHandle?.cancel()
        asyncTimeFlowHandle = nil
        clock = nil
    }
    
}

extension ContentViewModel {
    enum Content: Hashable {
        case timer, beVersion
    }
}
