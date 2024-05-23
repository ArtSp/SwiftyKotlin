package domain

import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import data.remote.models.toDomain
import data.remoteClientType.RemoteClientType
import domain.models.ServerDate
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class ChatUseCase(
    private val client: RemoteClientType
) {
    
    @NativeCoroutines
    fun getServerDate(): Flow<ServerDate> {
        return client.getServerDate().map { it.toDomain() }
    }
    
}