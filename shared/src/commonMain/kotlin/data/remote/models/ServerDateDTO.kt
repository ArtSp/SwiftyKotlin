package data.remote.models

import domain.models.ServerDate
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class ServerDateDTO(
    var source: String?,
    var date: Instant = Clock.System.now()
)

fun ServerDateDTO.toDomain(): ServerDate {
    return ServerDate(source, date)
}