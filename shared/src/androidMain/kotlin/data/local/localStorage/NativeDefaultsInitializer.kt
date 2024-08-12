package data.local.localStorage

import android.content.Context
import androidx.startup.Initializer

class NativeDefaultsInitializer: Initializer<NativeDefaults> {

    override fun create(context: Context): NativeDefaults {
        NativeDefaults.setContext(context)
        return NativeDefaults()
    }

    override fun dependencies(): List<Class<out Initializer<*>>> {
        return emptyList()
    }

}