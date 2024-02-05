package data.versionClientType.versionClient

import data.factory.remote.createHttpClient
import data.models.remote.AppVersionDTO
import data.models.remote.toDomain
import data.versionClientType.VersionClientType
import domain.models.AppError
import domain.models.AppException
import domain.models.AppVersion
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.utils.io.errors.*
import util.Constants

class KtorVersionClient(
    private val httpClient: HttpClient = createHttpClient()
): VersionClientType {
    
    private suspend fun request(
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

        when (response.status.value) {
            in 200..299 -> Unit
            500 -> throw AppException(AppError.ServerError("${response.status.value}"))
            in 400..499 -> throw AppException(AppError.ClientError("${response.status.value}"))
            else -> throw AppException(AppError.UnknownError)
        }

        return  response
    }
    override suspend fun getServerVersion(): AppVersion {
        return try {
            request(Constants.Path.GET_VERSION)
                .body<AppVersionDTO>()
                .toDomain()
        } catch (e: Exception) {
            throw AppException(AppError.ServerError("${e.message}"))
        }
    }
}