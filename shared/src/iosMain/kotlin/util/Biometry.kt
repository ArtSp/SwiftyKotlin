package util

import domain.models.AppError
import domain.models.BiometryType
import domain.models.LocalAuthenticationResult
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSError
import interop.*
import kotlinx.cinterop.ObjCObjectVar
import platform.LocalAuthentication.*
import platform.posix.err
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

@OptIn(ExperimentalForeignApi::class)
actual fun getLocalAuthenticationBiometryType(): BiometryType? {
    val context = LAContext()
    val error: kotlinx.cinterop.CPointer<ObjCObjectVar<NSError?>>? = null
    val policy: LAPolicy = LAPolicyDeviceOwnerAuthenticationWithBiometrics
    
    return if (context.canEvaluatePolicy(policy, error)) {
        context.biometryType.toDomain()
    } else {
        null
    }
}

actual suspend fun authenticateLocalUserWithBiometrics(localizedReason: String): LocalAuthenticationResult {
    return suspendCoroutine<LocalAuthenticationResult> { continuation ->
        val context = LAContext()
        val policy: LAPolicy = LAPolicyDeviceOwnerAuthenticationWithBiometrics
      
        context.evaluatePolicy(policy, localizedReason) { success, error ->
            if (success) {
                continuation.resume(LocalAuthenticationResult.Success)
            } else {
                val errorCode = error?.code?.toInt()
                println(kLAErrorUserCancel)
                println(errorCode)
                if (error?.code?.toInt() == kLAErrorUserCancel) {
                    continuation.resume(LocalAuthenticationResult.Cancel)
                } else {
                    error?.let {
                        continuation.resumeWith(Result.failure(AppError.ClientError(it.localizedDescription)))
                    } ?: run {
                        continuation.resumeWith(Result.failure(AppError.UnknownError))
                    }
                    
                }
            }
        }
    }
}

fun LABiometryType.toDomain(): BiometryType? {
    return when (this) {
        LABiometryTypeFaceID ->  BiometryType.FaceID
        LABiometryTypeTouchID -> BiometryType.TouchID
        LABiometryTypeOpticID -> BiometryType.OpticID
        else -> null
    }
}