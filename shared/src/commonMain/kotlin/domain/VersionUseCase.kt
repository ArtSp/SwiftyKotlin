package domain

import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import data.remote.models.toDomain
import data.remoteClientType.RemoteClientType
import domain.models.AppVersion
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.isActive
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toLocalDateTime
import util.getPlatform

class VersionUseCase(
   private val client: RemoteClientType
) {
    @NativeCoroutines
    @Throws(Exception::class)
    suspend fun getServerVersion(): AppVersion {
        return client.getServerVersion().toDomain()
    }

    fun getAppVersion(): AppVersion {
        val platform = getPlatform()
        return AppVersion(platform = platform.name, version = platform.version)
    }

    @NativeCoroutines
    fun timeFlow(): Flow<String> = flow { // flow builder
        while (currentCoroutineContext().isActive) {
            val now: Instant = Clock.System.now()
            val thisTime: LocalTime = now.toLocalDateTime(TimeZone.currentSystemDefault()).time
            emit(thisTime.toString())
            delay(1_000 / 60)
        }
    }

}