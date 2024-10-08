package data.local.localStorage

import platform.Foundation.NSUserDefaults

actual class NativeDefaults actual constructor() {

    private var defaults = NSUserDefaults.standardUserDefaults

    actual constructor(name: String) : this() {
        require(name != "Standard") {"'Standard' is reserved for Default's default implementation"}
        defaults = NSUserDefaults(suiteName = name)
    }

    actual fun setString(key: String, value: String) {
        defaults.setObject(value, key)
    }

    actual fun getString(key: String): String? {
        return defaults.stringForKey(key)
    }

    actual fun setInt(key: String, value: Int) {
        defaults.setObject(value, key)
    }

    actual fun getInt(key: String): Int? {
        return defaults.objectForKey(key) as? Int
    }

    actual fun setFloat(key: String, value: Float) {
        defaults.setDouble(value.toDouble(), key)
    }

    actual fun getFloat(key: String): Float? {
        return defaults.doubleForKey(key).toFloat()
    }

    actual fun setBoolean(key: String, value: Boolean) {
        defaults.setBool(value, key)
    }

    actual fun getBoolean(key: String): Boolean? {
        return defaults.boolForKey(key)
    }

    actual fun setStringSet(key: String, set: Set<String>) {
        defaults.setObject(set.toList(), key)
    }

    actual fun getStringSet(key: String): Set<String>? {
        val list = (defaults.objectForKey(key) as? List<*>)?.filterIsInstance<String>()
        return list?.toSet()
    }

    actual fun clearValue(key: String) {
        defaults.removeObjectForKey(key)
    }

}