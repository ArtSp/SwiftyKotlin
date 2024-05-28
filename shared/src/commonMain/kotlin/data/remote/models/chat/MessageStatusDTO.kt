package data.remote.models.chat

import kotlinx.serialization.Serializable

@Serializable
data class MessageStatusDTO(
    val isTyping: Boolean
)