package domain

import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import data.local.LocalStorageType
import data.remote.RemoteClientType
import data.remote.models.LoginDTO
import data.remote.models.toDTO
import data.remote.models.toDomain
import domain.models.AppError
import domain.models.AppState
import domain.models.Auth
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import util.getLocalAuthenticationBiometryType
import kotlin.coroutines.CoroutineContext

class AuthUseCase(
    private val client: RemoteClientType,
    private val localStorage: LocalStorageType
): CoroutineScope {
    override val coroutineContext: CoroutineContext = Job()
    var appState: AppState
        get() { return localStorage.appState }
        set(value) { localStorage.appState = value }

    init {
        launch {
            appState = appState.copy(
                localBiometryType = getLocalAuthenticationBiometryType()
            )
        }
    }

    @NativeCoroutines
    suspend fun login(userName: String, password: String) {
        val auth = client.login(LoginDTO(userName, password))
        setLoggedIn(auth.toDomain(), Auth.LockState.Unlocked(null))
    }

    fun lock() {
        //TODO: Not implemented
    }
    
    fun unlock() {
        //TODO: Not implemented
    }
    
    fun setLockState(lockState: Auth.LockState) {
        appState.authStatus?.auth?.let {
            if (lockState is Auth.LockState.Unlocked) {
                appState = appState.copy(authStatus = Auth.Status.LoggedIn(it, lockState))
            } else {
                appState = appState.copy(authStatus = Auth.Status.LoggedIn(it, Auth.LockState.Unlocked(lockState)))
            }
        }
    }
    
    private fun setLoggedIn(auth: Auth, lockState: Auth.LockState) {
        appState = appState.copy(authStatus = Auth.Status.LoggedIn(auth, lockState))
    }
}