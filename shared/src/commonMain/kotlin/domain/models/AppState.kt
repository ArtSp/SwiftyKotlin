package domain.models

import kotlinx.serialization.Serializable

@Serializable
data class AppState(
    var authStatus: Auth.Status? = null,
    var language: Language = Language.defaultLanguage,
    var localBiometryType: BiometryType? = null
)

