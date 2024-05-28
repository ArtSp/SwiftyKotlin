package data.remoteClientType.remoteClient

import data.remote.KtorClient
import data.remote.models.AppVersionDTO
import data.remote.models.ServerDateDTO
import data.remote.models.chat.MessageDTO
import data.remoteClientType.ChatInput
import data.remoteClientType.ChatOutput
import data.remoteClientType.RemoteClientType
import domain.models.AppError
import domain.models.AppException
import io.ktor.client.call.*
import io.ktor.client.plugins.websocket.*
import io.ktor.serialization.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import util.Constants

class KtorRemoteClient: RemoteClientType {

    private val httpClient: KtorClient = KtorClient()

    override suspend fun getServerVersion(): AppVersionDTO {
        return try {
            httpClient
                .get(Constants.Path.GET_VERSION)
                .body<AppVersionDTO>()
        } catch (e: Exception) {
            throw AppException(AppError.ServerError("${e.message}"))
        }
    }

    override fun getServerDate(): Flow<ServerDateDTO> {
        return flow {
            httpClient.getSocket(Constants.Path.WS_SERVER_TIME) {
                try {
                    for (frame in it.incoming) {
                        val serverDate: ServerDateDTO = it.converter?.deserialize(frame) ?: continue
                        this.emit(serverDate)
                    }
                } catch (e: Exception) {
                    throw AppException(AppError.ServerError("${e.message}"))
                }
            }
        }
    }

    override fun establishChatConnection(input: Flow<ChatInput>): Flow<ChatOutput> {
        TODO("Not yet implemented")
    }
}