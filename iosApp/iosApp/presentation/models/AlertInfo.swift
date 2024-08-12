
import Foundation

enum AlertInfo: Identifiable {
    var id: Int {
        switch self {
        case .error: return 0
        case .appError: return 1
        }
    }
    
    case error(Error)
    case appError(AppError)
}
