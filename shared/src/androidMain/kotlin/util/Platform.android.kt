package util

import android.os.Build


class AndroidPlatform : Platform {
    override val name: String = "Android ${Build.VERSION.SDK_INT}"
    override val version: String = "${Build.VERSION.RELEASE}"
    override val os: Platform.OS = Platform.OS.ANDROID
}

actual fun getPlatform(): Platform = AndroidPlatform()