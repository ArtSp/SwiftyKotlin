package util

import domain.models.BiometryType
import domain.models.LocalAuthenticationResult

expect fun getLocalAuthenticationBiometryType(): BiometryType?
expect suspend fun authenticateLocalUserWithBiometrics(localizedReason: String): LocalAuthenticationResult