package data.versionClientType.versionClient

import data.remote.KtorClient
import data.remote.models.AppVersionDTO
import data.remote.models.toDomain
import data.versionClientType.VersionClientType
import domain.models.AppError
import domain.models.AppException
import domain.models.AppVersion
import io.ktor.client.call.*
import util.Constants

class KtorVersionClient: VersionClientType {

    private val httpClient: KtorClient = KtorClient()

    override suspend fun getServerVersion(): AppVersion {
        return try {
            httpClient
                .get(Constants.Path.GET_VERSION)
                .body<AppVersionDTO>()
                .toDomain()
        } catch (e: Exception) {
            throw AppException(AppError.ServerError("${e.message}"))
        }
    }
}