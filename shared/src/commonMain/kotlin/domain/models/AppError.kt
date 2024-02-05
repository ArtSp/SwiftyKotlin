package domain.models

sealed class AppError(message: String): Throwable(message) {
    data class ClientError(override val message: String): AppError(message)
    data class ServerError(override val message: String): AppError(message)
    data object UnknownError: AppError("")
    data object ServiceUnavailable: AppError("")
}