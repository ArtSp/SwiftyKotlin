
import Foundation
import Shared
import KMPNativeCoroutinesAsync

// ViewModel(VM) File structure:
//
// 1 VM internal/public declaration
// 1.1 VM private variables
// 1.2 VM variables
// 1.3 VM init/deinit
// 1.4 VM computed variables
// 1.5 VM functions
//
// 2 VM private/fileprivate extension
// 2.1 VM computed variables (private/fileprivate)
// 2.1 VM functions (private/fileprivate)


// MARK: - 1
class ContentViewModel: ObservableObject {
    
    // MARK: - 1.1
    private let fakeVersionUseCase = VersionUseCase(client: FakeVersionClient())
    private let beVersionUseCase = VersionUseCase(client: KtorVersionClient())
    private var asyncTimeFlowHandle: Task<Void, Error>?
    private var asyncServerTimeFlowHandle: Task<Void, Error>?
    private var getBackendVersionTask: Task<Void, Error>?
    
    // MARK: - 1.2
    @Published var isLoading: Set<Content> = .init()
    @Published var error: AppError?
    @Published var appVersion: String?
    @Published var beVersion: String?
    @Published var clock: String?
    @Published var serverDate: ServerDate?
    @Published var counter: Int = 0
    @Published var useFake: Bool = true {
        didSet {
            appVersion = nil
            beVersion = nil
            loadInitialData()
        }
    }
    
    // MARK: - 1.3
    init() {
        loadInitialData()
    }
    
    // MARK: - 1.4
    var clockIsRunning: Bool { isLoading.contains(.timer) }
    var isLoadingRemoteVersion: Bool { isLoading.contains(.beVersion) }
    
    // MARK: - 1.5
    func loadInitialData() {
        loadLocalVersion()
        getBackendDateAsync()
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
    
}

// MARK: - 2

private extension ContentViewModel {
    
    // MARK: - 2.1
    
    var versionUseCase: VersionUseCase {
        // TODO: implement DI
        useFake ? fakeVersionUseCase : beVersionUseCase
    }
    
    // MARK: - 2.2
    
    // Use asyncFunction to create cancelable async call.
    // Without asyncFunction function will work async way but with no cancelation support.
    func getBackendVersionAsync() {
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
    
    func getBackendDateAsync() {
        serverDate = nil
        asyncServerTimeFlowHandle?.cancel()
        asyncServerTimeFlowHandle = Task { @MainActor in
            isLoading.insert(.serverDate); defer { isLoading.remove(.serverDate) }
            do {
                for try await element in asyncSequence(for: versionUseCase.getServerDate()) {
                    serverDate = element
                }
            } catch {
                self.error = error.appError
            }
        }
    }
    
    // Use asyncSequence to create cancelable async sequence call.
    // Without asyncSequence function will work in closure way, with no cancelation support.
    func startTimer() {
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
    func stopTimer() {
        asyncTimeFlowHandle?.cancel()
        asyncTimeFlowHandle = nil
        clock = nil
    }
    
}

// MARK: - 3

extension ContentViewModel {
    
    enum Content: Hashable {
        case timer, beVersion, serverDate
    }
}
