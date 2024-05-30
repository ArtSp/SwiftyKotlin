package util
import kotlinx.datetime.Instant
import java.text.SimpleDateFormat
import java.util.*

actual fun Instant.dateString(pattern: String): String? {
    return try {
        SimpleDateFormat(pattern).format(Date(this.toEpochMilliseconds()))
    } catch (e: Exception) {
        null
    }
}