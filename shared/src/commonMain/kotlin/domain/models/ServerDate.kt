package domain.models

import kotlinx.datetime.Instant

data class ServerDate(
    var source: String?,
    var date: Instant
)