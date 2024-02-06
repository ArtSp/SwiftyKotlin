package data.versionClientType.versionClient

import data.versionClientType.VersionClientType
import domain.models.AppVersion
import util.getPlatform

class FakeVersionClient: VersionClientType {
    override suspend fun getServerVersion(): AppVersion {
        return AppVersion(platform = "Fake BE", version = "0")
    }

}