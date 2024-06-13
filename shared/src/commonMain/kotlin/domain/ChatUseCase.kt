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
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlinx.datetime.Clock

class ChatUseCase(
    private val client: RemoteClientType
) {
    private var user: UserDTO? = null
    private val chatInputFlow = MutableSharedFlow<ChatInput>()
    private var chatOutputFlow = MutableSharedFlow<ChatOutput>()
    private val coroutineScope = CoroutineScope(Dispatchers.Default)
    private var messages: MutableList<ChatMessage> = mutableListOf()

    @NativeCoroutines
    fun getServerDate(): Flow<ServerDate> {
        return client.getServerDate().map { it.toDomain() }
    }
    
    @NativeCoroutines
    fun establishChatConnection(): Flow<List<ChatMessage>> {
        return flow {
            client
                .establishChatConnection(chatInputFlow)
                .onStart {
                    // FIXME: Not working, but works on line 87
                    coroutineScope.launch {
                        chatInputFlow.emit(ChatInput.Connect(UserConnectionDTO(name = "Bob")))
                    }
                }
                .collect {
                    when (it) {
                        is ChatOutput.Connections -> {
                            println("There are ${it.connectionsDTO.count} connections")
                        }
                        is ChatOutput.MessageStatus -> {
                        // TODO: not implemented
                        }

                        is ChatOutput.User -> {
                            user = it.userDTO
                            println("User connected from os ${it.userDTO.os}")
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

        // NOTE: Remove when fixed --
        if (user == null) {
            chatInputFlow.emit(ChatInput.Connect(UserConnectionDTO(name = "Dubina")))
        }
        // --
    }
}

private fun MessageDTO.theme(): ChatMessage.Theme {
    return when (sender.os) {
        UserDTO.OS.ANDROID -> ChatMessage.Theme.GREEN
        UserDTO.OS.IOS -> ChatMessage.Theme.BLUE
    }
}