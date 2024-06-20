package domain

import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import data.remote.models.chat.MessageDTO
import data.remote.models.chat.UserConnectionDTO
import data.remote.models.chat.UserDTO
import data.remote.models.toDomain
import data.remoteClientType.ChatInput
import data.remoteClientType.ChatOutput
import data.remoteClientType.RemoteClientType
import domain.models.ServerDate
import domain.models.chat.ChatMessage
import kotlinx.coroutines.flow.*
import kotlinx.datetime.Clock

class ChatUseCase(
    private val client: RemoteClientType
) {

    private var user: UserDTO? = null
    private val chatInputFlow = MutableSharedFlow<ChatInput>()
    private var messages: MutableList<ChatMessage> = mutableListOf()

    @NativeCoroutines
    val connectionsFlow = MutableSharedFlow<Int>()


    @NativeCoroutines
    fun getServerDate(): Flow<ServerDate> {
        return client.getServerDate().map { it.toDomain() }
    }
    
    @NativeCoroutines
    fun establishChatConnection(userName: String): Flow<List<ChatMessage>> {
        return flow {
            client
                .establishChatConnection(
                    chatInputFlow
                        .onStart {
                            emit(ChatInput.Connect(UserConnectionDTO(userName)))
                        }
                )
                .onCompletion {
                    connectionsFlow.emit(0)
                }
                .collect {
                    when (it) {
                        is ChatOutput.Connections -> {
                            connectionsFlow.emit(it.connectionsDTO.count)
                        }
                        
                        is ChatOutput.MessageStatus -> {
                        // TODO: not implemented
                        }

                        is ChatOutput.User -> {
                            user = it.userDTO
                        }

                        is ChatOutput.Message -> {
                            it.messageDTO.let { msg ->
                                messages.add(
                                    ChatMessage(
                                        sender = msg.sender.name,
                                        text = msg.message,
                                        date = msg.date,
                                        theme = msg.theme(),
                                        isLocal = msg.sender.id == user?.id
                                    )
                                )
                                emit(messages)
                            }
                        }
                    }
                }
        }
    }

    @NativeCoroutines
    suspend fun sendMessage(text: String) {
        user?.let {
            val messageDTO = MessageDTO(
                sender = it,
                date = Clock.System.now(),
                message = text
            )
            chatInputFlow.emit(ChatInput.Message(messageDTO))
        }
    }
}

private fun MessageDTO.theme(): ChatMessage.Theme {
    return when (sender.os) {
        UserDTO.OS.ANDROID -> ChatMessage.Theme.GREEN
        UserDTO.OS.IOS -> ChatMessage.Theme.BLUE
    }
}