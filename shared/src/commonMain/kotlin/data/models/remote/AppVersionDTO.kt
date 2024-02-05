package data.models.remote

import domain.models.AppVersion
import kotlinx.serialization.Serializable

@Serializable
data class AppVersionDTO(
    val platform: String,
    val version: String 
)

fun AppVersionDTO.toDomain(): AppVersion {
    return AppVersion(platform, version)
}