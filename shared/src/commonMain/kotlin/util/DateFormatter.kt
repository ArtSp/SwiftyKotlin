package util

import kotlinx.datetime.Instant

expect fun Instant.dateString(pattern: String): String?