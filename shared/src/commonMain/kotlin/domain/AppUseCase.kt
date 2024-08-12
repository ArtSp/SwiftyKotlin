package domain

import com.rickclephas.kmp.nativecoroutines.NativeCoroutines
import data.local.LocalStorageType
import data.remote.RemoteClientType
import data.remote.models.toDomain
import domain.models.AppState
import domain.models.AppUpdate
import domain.models.AppVersion
import domain.models.Language
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import util.dateString
import util.getCurrency
import util.getPlatform
import kotlin.coroutines.CoroutineContext

class AppUseCase(
   private val client: RemoteClientType,
   private val localStorage: LocalStorageType
) : CoroutineScope {
    
    override val coroutineContext: CoroutineContext = Job()
    var appState: AppState
        get() { return localStorage.appState }
        set(value) { localStorage.appState = value }
    
    @NativeCoroutines
    suspend fun checkForUpdates(): AppUpdate? {
        return client.checkForUpdates()?.toDomain()?.also {
            appState = appState.copy(update = it)
        }
    }
    
    fun getLocalToUSDCurrency(
        localVal: Double
    ): String? {
        // TODO: Find & implement some public API for conversion
        return (localVal * 1.23).getCurrency(currencyCode = "USD")
    }
    
    @NativeCoroutines
    @Throws(Exception::class)
    suspend fun getServerVersion(): AppVersion {
        return client.getServerVersion().toDomain()
    }

    fun getAppVersion(): AppVersion {
        val platform = getPlatform()
        return AppVersion(platform = platform.name, version = platform.version)
    }

    @NativeCoroutines
    fun timeFlow(
        dateFormat: String
    ): Flow<String> = flow { // flow builder
        while (currentCoroutineContext().isActive) {
            val now: Instant = Clock.System.now()
            val dateStr =  now.dateString(dateFormat)
            dateStr?.let {
                emit(it)
            }
            delay(1_000 / 60)
        }
    }
    
    // This just saves prefered language. Actual localization must be implemented per platform
    fun setLanguage(language: Language) {
        appState = appState.copy(language = language)
    }
}
