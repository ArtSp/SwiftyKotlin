
import MPSwiftUI

extension View {
    
    /// Handles Alerts with default implementation
    func handleAlert(
        item: Binding<AlertInfo?>,
        alertBuilder: ((AlertInfo) -> Alert?)? = nil
    ) -> some View {
        self.alert(item: item) { item in
            switch item {
            case let .error(error):
                return Alert(title: Text(error.localizedDescription.localizedStringKey))
                
            case let .appError(appError):
                return Alert(
                    title: Text(appError.title),
                    message: appError.message == nil ? nil : Text(appError.message!)
                )
                
            default:
                if let alertBuilder = alertBuilder {
                    return alertBuilder(item) ?? Alert(title: Text("Unknown error"))
                } else {
                    return Alert(title: Text("Unknown error"))
                }
            }

        }
    }
    
    var localizedByBundle: some View {
        self.modifier(BundleLocalizationModifier())
    }
    
    private static var shimmerDefaultDelay: TimeInterval { 0.5 }
    
    func shimmed(id: AnyHashable = .zero, _ condition: Bool = true) -> some View {
        shimmed(id: id, condition, shimmerDelay: Self.shimmerDefaultDelay)
    }
    
    func shimmedAndRedacted(id: AnyHashable = .zero, _ condition: Bool = true) -> some View {
        shimmedAndRedacted(id: id, condition, shimmerDelay: Self.shimmerDefaultDelay)
    }
    
}

private struct BundleLocalizationModifier: ViewModifier {
    
    @Preference(\.bundleLanguage) var bundleLanguage
    
    func body(content: Content) -> some View {
        content
            .locale(bundleLanguage.locale)
    }
}
