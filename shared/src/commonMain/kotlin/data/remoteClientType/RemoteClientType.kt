package data.remoteClientType

import data.remote.models.AppVersionDTO
import data.remote.models.ServerDateDTO
import data.remote.models.chat.*
import kotlinx.coroutines.flow.Flow

interface RemoteClientType {
    suspend fun getServerVersion(): AppVersionDTO
    fun getServerDate(): Flow<ServerDateDTO>
    suspend fun establishChatConnection(input: Flow<ChatInput>): Flow<ChatOutput>
}

sealed class ChatInput {
    data class Connect(val userConnectionDTO: UserConnectionDTO): ChatInput()
    data class Typing(val isTyping: Boolean): ChatInput()
    data class Message(val messageDTO: MessageDTO): ChatInput()
}

sealed class ChatOutput {
    data class MessageStatus(val messageStatusDTO: MessageStatusDTO): ChatOutput()
    data class Message(val messageDTO: MessageDTO): ChatOutput()
    data class User(val userDTO: UserDTO): ChatOutput()
    data class Connections(val connectionsDTO: ConnectionsDTO): ChatOutput()
}