package domain.models

import kotlinx.serialization.Serializable

@Serializable
data class AppUpdate(
    val url: String?,
    val isReqired: Boolean
)