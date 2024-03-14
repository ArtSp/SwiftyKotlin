package domain.models

sealed class AppError(message: String, val title: String): Throwable(message) {
    data class ClientError(override val message: String): AppError(message, kClientError)
    data class ServerError(override val message: String): AppError(message, kServerError)
    data object UnknownError: AppError("", kUnknownError)
    data object ServiceUnavailable: AppError("", kServiceUnavailable)

    companion object {
        const val kClientError = "Client Error"
        const val kServerError = "Server Error"
        const val kUnknownError = "Unknown Error"
        const val kServiceUnavailable = "Service Unavailable"
    }
}