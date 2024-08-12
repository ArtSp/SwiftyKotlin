package domain.models

import kotlinx.serialization.Serializable

@Serializable
data class AppState(
    var authStatus: Auth.Status = Auth.Status.Unauthorized,
    var language: Language = Language.defaultLanguage,
    var localBiometryType: BiometryType? = null,
    var update: AppUpdate? = null
)

