package util

import domain.models.AppError
import domain.models.LocalAuthenticationResult
import kotlinx.serialization.Serializable

@Serializable class DataLocker<T> {
    private var lock: Lock? = null
    private var data: T? = null
    private var localizedReason: String? = null
    val unlocksWith: List<LockType>? get() { return lock?.lockTypes }
    
    enum class LockType { Secret, Biometrics }
    
    @Serializable sealed class Lock(val lockTypes: List<LockType>) {
        @Serializable data object Biometrics: Lock(listOf(LockType.Biometrics))
        @Serializable data class PinOrBiometrics(val pin: String): Lock(listOf(LockType.Secret, LockType.Biometrics))
        @Serializable data class Pin(val pin: String): Lock(listOf(LockType.Secret))
    }
    
    @Serializable sealed class LockKey(val lockType: LockType) {
        @Serializable data object Biometrics: LockKey(LockType.Biometrics)
        @Serializable data class Pin(val pin: String): LockKey(LockType.Secret)
    }
    
    fun set(data: T?) {
        this.data = data
    }
        
    fun set(lock: Lock?, localizedReason: String?) {
        this.lock = lock
        this.localizedReason = localizedReason
    }
    
    suspend fun getData(key: LockKey?): T? {
        if (key == null && lock == null) {
            return data
        } else if (key != null && unlocksWith?.contains(key.lockType) == true) {
            val unlocked: Boolean = when (key) {
                is LockKey.Biometrics -> {
                    authenticateLocalUserWithBiometrics(localizedReason ?: "") == LocalAuthenticationResult.Success
                }
                is LockKey.Pin -> {
                    val pin = (lock as? Lock.Pin)?.pin ?: (lock as? Lock.PinOrBiometrics)?.pin
                    key.pin == pin
                }
            }
            return if (unlocked) data else throw AppError.ClientError("Invalid key")
        } else {
            throw AppError.UnknownError
        }
    }
}