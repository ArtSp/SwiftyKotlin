package domain.models
class AppException(private val error: AppError): Exception(error)