package domain.models.chat

import kotlinx.datetime.Instant

data class ChatMessage (
    val sender: String,
    val text: String,
    val date: Instant,
    val theme: Theme,
    val isLocal: Boolean
) {
    enum class Theme { BLUE, GREEN }
}