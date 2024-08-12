package util

import domain.models.AppError
import domain.models.BiometryType
import domain.models.LocalAuthenticationResult

actual fun getLocalAuthenticationBiometryType(): BiometryType? {
    throw AppError.ClientError("Not implemented")
}

actual suspend fun authenticateLocalUserWithBiometrics(localizedReason: String): LocalAuthenticationResult {
    throw AppError.ClientError("Not implemented")
}