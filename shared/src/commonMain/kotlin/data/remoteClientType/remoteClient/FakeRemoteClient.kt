package data.remoteClientType.remoteClient

import data.remote.models.AppVersionDTO
import data.remote.models.ServerDateDTO
import data.remoteClientType.RemoteClientType
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.datetime.Clock
import kotlin.time.Duration.Companion.seconds

class FakeRemoteClient: RemoteClientType {

    private var version = AppVersionDTO(platform = "Fake BE", version = "0")

    override suspend fun getServerVersion(): AppVersionDTO {
        return version
    }

    override fun getServerDate(): Flow<ServerDateDTO> {
        return flow {
            while (true) {
                val date = ServerDateDTO(version.platform, Clock.System.now())
                emit(date)
                delay(10.seconds)
            }
        }
    }
}