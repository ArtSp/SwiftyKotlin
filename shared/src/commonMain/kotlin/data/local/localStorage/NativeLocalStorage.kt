package data.local.localStorage

import data.local.LocalStorageType
import domain.models.AppState
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class NativeLocalStorage: LocalStorageType {

    private var defaults = NativeDefaults()
    
    override var appState: AppState
        get() {
            val serialized = defaults.getString("appState")
            if (serialized != null) {
                val deserialized = Json.decodeFromString<AppState>(serialized)
                return deserialized
            } else {
                return AppState()
            }
        }
        set(value) {
            val serialized = Json.encodeToString(value)
            defaults.setString("appState", serialized)
        }
}