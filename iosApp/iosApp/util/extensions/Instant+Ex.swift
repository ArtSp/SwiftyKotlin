
import Foundation
import Shared

extension Kotlinx_datetimeInstant {
    
    var swiftDate: Date {
        Date(timeIntervalSince1970: Double(self.epochSeconds))
    }
}
