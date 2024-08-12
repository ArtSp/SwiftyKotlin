package data.remote.models

import domain.models.AppUpdate
import kotlinx.serialization.Serializable

@Serializable
data class AppUpdateDTO(
    val url: String?,
    val isReqired: Boolean
)

fun AppUpdateDTO.toDomain(): AppUpdate {
    return AppUpdate(url, isReqired)
}