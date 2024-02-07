package data.remote

import domain.models.AppError
import domain.models.AppException
import io.ktor.client.*
import io.ktor.client.request.accept
import io.ktor.client.request.get
import io.ktor.client.request.url
import io.ktor.client.statement.HttpResponse
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.utils.io.errors.IOException
import util.Constants

expect fun createHttpClient(): HttpClient
class KtorClient {

    private val httpClient: HttpClient = createHttpClient()
    @Throws(Exception::class)
    suspend fun get(
        path: String
    ): HttpResponse {
        val response = try {
            httpClient.get {
                url(Constants.BASE_URL + path)
                contentType(ContentType.Application.Json)
                accept(ContentType.Application.Json)
            }
        } catch (e: IOException) {
            throw AppException(AppError.ServiceUnavailable)
        }

        handleResponseStatus(response)

        return  response
    }

    private fun handleResponseStatus(response: HttpResponse) {
        when (response.status.value) {
            in 200..299 -> Unit
            500 -> throw AppException(AppError.ServerError("${response.status.value}"))
            in 400..499 -> throw AppException(AppError.ClientError("${response.status.value}"))
            else -> throw AppException(AppError.UnknownError)
        }
    }
}


