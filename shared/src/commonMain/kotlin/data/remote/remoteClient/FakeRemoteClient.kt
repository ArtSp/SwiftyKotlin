package data.remote.remoteClient

import data.remote.ChatInput
import data.remote.ChatOutput
import data.remote.RemoteClientType
import data.remote.models.*
import data.remote.models.chat.ConnectionsDTO
import data.remote.models.chat.UserDTO
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.datetime.Clock
import util.Platform
import util.getPlatform
import kotlin.random.Random
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds

class FakeRemoteClient: RemoteClientType {

    private val requestDelayDuration: Duration get() { return Random.nextDouble(0.1, 1.0).seconds }
    private var serverVersion = AppVersionDTO(platform = "Fake BE", version = "0")
    private val platform = getPlatform()

    override suspend fun login(login: LoginDTO): AuthDTO {
        delay(requestDelayDuration)
        return AuthDTO(authToken = "authToken", refreshToken = "refreshToken", expirationDate = null)
    }

    override suspend fun logout(auth: AuthDTO) {
        delay(requestDelayDuration)
    }
    
    override suspend fun checkForUpdates(): AppUpdateDTO? {
        delay(requestDelayDuration)
        return null
//        return AppUpdateDTO(url = "127.0.0.1", isReqired = true)
    }

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

    override fun establishChatConnection(input: Flow<ChatInput>): Flow<ChatOutput> {
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