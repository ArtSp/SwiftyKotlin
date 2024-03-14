
import Foundation
import Shared

extension Error {
    var appError: AppError? {
        appException?.cause as? AppError
    }
    
    var appException: AppException? {
        (self as NSError).kotlinException as? AppException
    }
}
