package data.versionClientType

import domain.models.AppVersion

interface VersionClientType {
    @Throws(Exception::class)
    suspend fun getServerVersion(): AppVersion
}