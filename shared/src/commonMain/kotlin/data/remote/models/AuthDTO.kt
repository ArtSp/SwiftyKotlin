package data.remote.models

import domain.models.Auth
import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class AuthDTO(
    val authToken: String,
    val refreshToken: String,
    val expirationDate: Instant?
)

fun Auth.toDTO(): AuthDTO {
    return AuthDTO(
        authToken,
        refreshToken,
        expirationDate
    )
}

fun AuthDTO.toDomain(): Auth {
    return Auth(
        authToken,
        refreshToken,
        expirationDate
    )
}