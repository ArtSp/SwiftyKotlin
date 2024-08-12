package domain

import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import data.remote.ChatInput
import data.remote.ChatOutput
import data.remote.RemoteClientType
import data.remote.models.chat.MessageDTO
import data.remote.models.chat.MessageStatusDTO
import data.remote.models.chat.UserConnectionDTO
import data.remote.models.chat.UserDTO
import data.remote.models.toDomain
import domain.models.ServerDate
import domain.models.chat.ChatMessage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import kotlin.coroutines.CoroutineContext
import kotlin.time.Duration.Companion.seconds

class ChatUseCase(
    private val client: RemoteClientType
): CoroutineScope {

    override val coroutineContext: CoroutineContext = Job()
    private var user: UserDTO? = null
    private val chatInputFlow = MutableSharedFlow<ChatInput>()
    private var messages: MutableList<ChatMessage> = mutableListOf()

    private val _localIsTypingFlow = MutableSharedFlow<Boolean>()
    private val _remoteIsTypingFlow = MutableSharedFlow<Boolean>()

    @NativeCoroutines
    val connectionsFlow = MutableSharedFlow<Int>()
    @NativeCoroutines
    val remoteIsTypingFlow = MutableSharedFlow<Boolean>()

    init {
        handleTyping()
    }

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
                            _remoteIsTypingFlow.emit(it.messageStatusDTO.isTyping)
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

    fun sendIsTyping() {
        launch { _localIsTypingFlow.emit(true) }
    }

    private fun handleTyping() {
        // Send events
        launch {
            _localIsTypingFlow
                .sample(1.seconds)
                .collect {
                    user?.let {
                        val messageStatus = MessageStatusDTO(it, true)
                        chatInputFlow.emit(ChatInput.Typing(messageStatus))
                    }
                }
        }

        // Receive events
        launch {
            _remoteIsTypingFlow
                .onEach { remoteIsTypingFlow.emit(it) }
                .debounce(3.seconds)
                .filter { it }
                .collect { remoteIsTypingFlow.emit(false) }
        }
    }
}

private fun MessageDTO.theme(): ChatMessage.Theme {
    return when (sender.os) {
        UserDTO.OS.ANDROID -> ChatMessage.Theme.GREEN
        UserDTO.OS.IOS -> ChatMessage.Theme.BLUE
    }
}