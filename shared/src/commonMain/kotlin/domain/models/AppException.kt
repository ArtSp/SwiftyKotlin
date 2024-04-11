package domain.models

class AppException(error: AppError): Exception(error.message, error)