package domain

import data.versionClientType.VersionClientType
import domain.models.AppVersion

class VersionUseCase(
   private val client: VersionClientType
) {
    suspend fun getServerVersion(): AppVersion {
        return client.getServerVersion()
    }
}