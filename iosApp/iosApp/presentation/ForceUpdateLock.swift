
import MPSwiftUI

// MARK: - EnvironmentValues

public extension EnvironmentValues {
    var updateRequired: Bool {
        get { self[UpdateRequiredKey.self] }
        set { self[UpdateRequiredKey.self] = newValue }
    }
}

public struct UpdateRequiredKey: EnvironmentKey {
    public static let defaultValue: Bool = false
}
