package domain.models

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class Auth(
    val authToken: String,
    val refreshToken: String,
    val expirationDate: Instant?
) {
    @Serializable
    sealed class LockState(val isLocked: Boolean = true) {

        @Serializable
        data class LockedWithPinOrBiometrics(val pin: String): LockState() {
            
        }
        @Serializable
        data class LockedWithPin(val pin: String): LockState()
        @Serializable
        data class Unlocked(val lockState: LockState?): LockState(false) {
            init { require(lockState !is Unlocked) }
        }
    }
    
    @Serializable
    sealed class Status {
        abstract val auth: Auth?
        abstract val lockState: LockState?

        val isLoggedIn: Boolean get() { return auth != null }

        @Serializable
        data object Unauthorized: Status() {
            override val auth: Auth? = null
            override val lockState: LockState? = null
        }
        @Serializable
        data class LoggedIn(
            override val auth: Auth,
            override val lockState: LockState
        ): Status()
    }
}