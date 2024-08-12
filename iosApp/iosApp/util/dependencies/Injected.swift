
import Foundation

@propertyWrapper
struct Injected<T> {

    private let keyPath: WritableKeyPath<DependencyInjection, T>
    
    var wrappedValue: T {
        get { DependencyInjection.assembly[keyPath: keyPath] }
        set { DependencyInjection.assembly[keyPath: keyPath] = newValue }
    }
    
    init(
        _ keyPath: WritableKeyPath<DependencyInjection, T>
    ) {
        self.keyPath = keyPath
    }
}

extension ProcessInfo {
    
    var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
