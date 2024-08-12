package data.remote

import data.remote.models.*
import data.remote.models.chat.*
import kotlinx.coroutines.flow.Flow

interface RemoteClientType {
    suspend fun login(login: LoginDTO): AuthDTO
    suspend fun logout(auth: AuthDTO)
    suspend fun getServerVersion(): AppVersionDTO
    suspend fun checkForUpdates(): AppUpdateDTO?
    fun getServerDate(): Flow<ServerDateDTO>
    fun establishChatConnection(input: Flow<ChatInput>): Flow<ChatOutput>
}

sealed class ChatInput {
    data class Connect(val userConnectionDTO: UserConnectionDTO): ChatInput()
    data class Typing(val messageStatusDTO: MessageStatusDTO): ChatInput()
    data class Message(val messageDTO: MessageDTO): ChatInput()
}

sealed class ChatOutput {
    data class MessageStatus(val messageStatusDTO: MessageStatusDTO): ChatOutput()
    data class Message(val messageDTO: MessageDTO): ChatOutput()
    data class User(val userDTO: UserDTO): ChatOutput()
    data class Connections(val connectionsDTO: ConnectionsDTO): ChatOutput()
}