
import Foundation

extension Language: Identifiable, Localized {
    
    var locale: Locale {
        let locale = Locale(identifier: code)
        return locale
    }
    
    public var id: String { code }
    var code: String { name }
    var isRTL: Bool { false }
    
    func shortName(locale: Locale?) -> String {
        switch self {
        case .english:  "EN"
        case .russian:  "RU"
        default:        "NA"
        }
    }

}
