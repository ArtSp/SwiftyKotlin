package domain

import data.versionClientType.VersionClientType
import domain.models.AppVersion
import util.getPlatform

class VersionUseCase(
   private val client: VersionClientType
) {
    @Throws(Exception::class)
    suspend fun getServerVersion(): AppVersion {
        return client.getServerVersion()
    }

    fun getAppVersion(): AppVersion {
        val platform = getPlatform()
        return AppVersion(platform = platform.name, version = "0")
    }
}