
import Foundation
import Combine

extension MainView: Screen {
    
    enum Destination: Hashable {
        case chat(userName: String)
    }
    
    enum LoadingContent {
        case timer, beVersion
    }
}

class MainViewModel: ScreenViewModel<MainView> {
    
    @Published var appVersion: String?
    @Published var beVersion: String?
    @Published var clock: String?
    @Published var counter: Int = 0
    @Published var userName: String = "User"
    @Published var localCurrencyVal: String = ""
    @Published var convertedCurrencyVal: String = ""
    
    private var asyncTimeFlowHandle: Task<Void, Error>?
    private var getBackendVersionTask: Task<Void, Error>?
    
    override init() {
        super.init()
        
        loadInitialData()
    }
    
    var clockIsRunning: Bool { isLoading.contains(.timer) }
    var isLoadingRemoteVersion: Bool { isLoading.contains(.beVersion) }
    
    func loadInitialData() {
        loadLocalVersion()
    }
    
    func loadLocalVersion() {
        let version = appUseCase.getAppVersion()
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
    
    func convertCurrency() {
        if let localValue = Double(localCurrencyVal) {
            convertedCurrencyVal = appUseCase
                .getLocalToUSDCurrency(localVal: localValue) ?? ""
        } else {
            convertedCurrencyVal = ""
        }
    }
    
    // Use asyncFunction to create cancelable async call.
    // Without asyncFunction function will work async way but with no cancelation support.
    private func getBackendVersionAsync() {
        getBackendVersionTask?.cancel()
        getBackendVersionTask = Task { @MainActor in
            isLoading.insert(.beVersion); defer { isLoading.remove(.beVersion) }
            do {
                let version = try await asyncFunction(for: appUseCase.getServerVersion())
                beVersion = [version.platform, version.version].joined(separator: " ")
            } catch {
                self.alert = error.alertInfo
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
                for try await element in asyncSequence(
                    for: appUseCase.timeFlow(
                        dateFormat: "dd-MM-yyyy HH:mm:ss"
                    )
                ) {
                    clock = element
                }
            } catch {
                self.alert = error.alertInfo
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

