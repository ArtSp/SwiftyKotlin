package data.remoteClientType

import data.remote.models.AppVersionDTO
import data.remote.models.ServerDateDTO
import kotlinx.coroutines.flow.Flow

interface RemoteClientType {
    @Throws(Exception::class)
    suspend fun getServerVersion(): AppVersionDTO
    @Throws(Exception::class)
    fun getServerDate(): Flow<ServerDateDTO>
}