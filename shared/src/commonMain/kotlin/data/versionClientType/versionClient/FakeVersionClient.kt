package data.versionClientType.versionClient

import data.versionClientType.VersionClientType
import domain.models.AppVersion
import util.getPlatform

class FakeVersionClient: VersionClientType {
    
    private val platform = getPlatform()
    override suspend fun getServerVersion(): AppVersion {
        return AppVersion(platform = platform.name, version = "0")
    }

}