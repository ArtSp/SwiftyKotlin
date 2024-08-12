package data.remote.remoteClient

import data.remote.ChatInput
import data.remote.ChatOutput
import data.remote.KtorClient
import data.remote.RemoteClientType
import data.remote.models.AppVersionDTO
import data.remote.models.AuthDTO
import data.remote.models.LoginDTO
import data.remote.models.ServerDateDTO
import data.remote.models.chat.*
import domain.models.AppError
import domain.models.AppException
import io.ktor.client.call.*
import io.ktor.client.plugins.websocket.*
import io.ktor.serialization.*
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import util.Constants

class KtorRemoteClient: RemoteClientType{

    private val httpClient: KtorClient = KtorClient()

    override suspend fun login(login: LoginDTO): AuthDTO {
        TODO("Not yet implemented")
    }

    override suspend fun logout(auth: AuthDTO) {
        TODO("Not yet implemented")
    }
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
        return flow {
            httpClient.getSocket(Constants.Path.WS_SERVER_CHAT) {
                CoroutineScope(it.coroutineContext).launch { it.outgoingMessages(input) }
                it.incomingMessages(this)
            }
        }
    }
}

private suspend fun DefaultClientWebSocketSession.outgoingMessages(input: Flow<ChatInput>) {
    input.collect {
        when (it) {
            is ChatInput.Connect ->
                sendSerialized(it.userConnectionDTO)
            is ChatInput.Message ->
                sendSerialized(it.messageDTO)
            is ChatInput.Typing -> {
                sendSerialized(it.messageStatusDTO)
            }
        }
    }
}

private suspend fun DefaultClientWebSocketSession.incomingMessages(output: FlowCollector<ChatOutput>) {
    try {
        for (frame in incoming) {
            try {
                converter?.deserialize<ConnectionsDTO>(frame)?.let {
                    output.emit(ChatOutput.Connections(it))
                }
            } catch (_: Throwable) {  }

            try {
                converter?.deserialize<UserDTO>(frame)?.let {
                    output.emit(ChatOutput.User(it))
                }
            } catch (_: Throwable) {  }

            try {
                converter?.deserialize<MessageDTO>(frame)?.let {
                    output.emit(ChatOutput.Message(it))
                }
            } catch (_: Throwable) {  }

            try {
                converter?.deserialize<MessageStatusDTO>(frame)?.let {
                    output.emit(ChatOutput.MessageStatus(it))
                }
            } catch (_: Throwable) {  }
        }
    } catch (e: Exception) {
        println("Error while receiving: " + e.message)
    }
}

