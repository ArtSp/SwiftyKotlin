package domain.models

class AppException(error: AppError): Exception(
    message = error.message,
    cause = error
)