package data.versionClientType

import domain.models.AppVersion

interface VersionClientType {
    suspend fun getServerVersion(): AppVersion
}