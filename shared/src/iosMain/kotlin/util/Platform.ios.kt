package util

import platform.UIKit.UIDevice
import platform.Foundation.NSBundle

class IOSPlatform: Platform {
    override val name: String = UIDevice.currentDevice.systemName() + " " + UIDevice.currentDevice.systemVersion
    override val version: String = NSBundle.mainBundle().infoDictionary?.getValue("CFBundleShortVersionString") as? String ?: "Unknown"
}

actual fun getPlatform(): Platform = IOSPlatform()