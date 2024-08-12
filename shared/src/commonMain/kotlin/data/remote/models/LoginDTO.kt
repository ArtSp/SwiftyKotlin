package data.remote.models

import kotlinx.serialization.Serializable

@Serializable
data class LoginDTO (
    val userName: String,
    val password: String
)