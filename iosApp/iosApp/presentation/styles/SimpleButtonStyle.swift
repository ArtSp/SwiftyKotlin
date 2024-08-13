
import Foundation
import MPSwiftUI

extension ButtonStyle where Self == SimpleButtonStyle {
    
    static var simpleButton: SimpleButtonStyle {
        SimpleButtonStyle(theme: .primary, fillWidth: false)
    }
    
    static func simpleButton(
        theme: SimpleButtonStyle.Theme,
        fillWidth: Bool = false
    ) -> SimpleButtonStyle {
        SimpleButtonStyle(theme: theme, fillWidth: fillWidth)
    }
}

extension SimpleButtonStyle {
    enum Theme {
        case primary
        case secondary
        
        var foregroundColor: Color {
            switch self {
            case .secondary: return .black
            default: return .white
            }
        }
        
        var strokeColor: Color {
            switch self {
            case .secondary: return .black
            default: return .clear
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .black
            case .secondary: return .white
            }
        }
    }
}

struct SimpleButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    @Environment(\.locale) var locale
    let theme: Theme
    let fillWidth: Bool
    
    let shape = RoundedRectangle(cornerRadius: 4)
    
    func background(configuration: Configuration) -> some View {
        ZStack {
            theme.backgroundColor
                .opacity(configuration.isPressed ? 0.8: 1)
        }
        .overlay {
            shape
                .stroke(lineWidth: 2)
                .foregroundStyle(theme.strokeColor)
        }
        .clipShape(shape)
        
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minHeight: 24)
            .if(fillWidth) { $0.frame(maxWidth: .infinity, alignment: .center) }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundStyle(theme.foregroundColor)
            .background(background(configuration: configuration))
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.4)
    }

}

#Preview {
    VStack {
        Button("Disabled") { }
            .buttonStyle(.simpleButton(theme: .primary))
            .disabled(true)
        
        Button("Primary") { }
            .buttonStyle(.simpleButton(theme: .primary))
        
        Button("Secondary") { }
            .buttonStyle(.simpleButton(theme: .secondary))
    }
}
