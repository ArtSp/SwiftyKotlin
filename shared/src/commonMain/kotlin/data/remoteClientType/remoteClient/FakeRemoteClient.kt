package data.remoteClientType.remoteClient

import data.remote.models.AppVersionDTO
import data.remote.models.ServerDateDTO
import data.remote.models.chat.ConnectionsDTO
import data.remote.models.chat.MessageStatusDTO
import data.remote.models.chat.UserDTO
import data.remoteClientType.ChatInput
import data.remoteClientType.ChatOutput
import data.remoteClientType.RemoteClientType
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.datetime.Clock
import util.Platform
import util.getPlatform
import kotlin.time.Duration.Companion.seconds

class FakeRemoteClient: RemoteClientType {

    private var serverVersion = AppVersionDTO(platform = "Fake BE", version = "0")
    private val platform = getPlatform()

    override suspend fun getServerVersion(): AppVersionDTO {
        return serverVersion
    }

    override fun getServerDate(): Flow<ServerDateDTO> {
        return flow {
            while (true) {
                val date = ServerDateDTO(serverVersion.platform, Clock.System.now())
                emit(date)
                delay(1.seconds)
            }
        }
    }

    override suspend fun establishChatConnection(input: Flow<ChatInput>): Flow<ChatOutput> {
        return flow {
            input
                .onStart {
                    emit(ChatOutput.Connections(ConnectionsDTO(count = 1) ))
                }
                .collect {
                    when (it) {
                        is ChatInput.Connect -> {
                            val userDTO = UserDTO(
                                id = "-1",
                                name = it.userConnectionDTO.name,
                                os = if (platform.os == Platform.OS.IOS) UserDTO.OS.IOS else UserDTO.OS.ANDROID
                            )
                            emit(ChatOutput.User(userDTO))
                        }

                        is ChatInput.Message -> {
                            delay(1.seconds)
                            emit(ChatOutput.Message(it.messageDTO))
                        }

                        is ChatInput.Typing -> {
                            delay(0.5.seconds)
                            emit(ChatOutput.MessageStatus(it.messageStatusDTO))
                        }

                    }
                }
        }
    }
}