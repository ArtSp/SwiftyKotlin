package util

class JVMPlatform: Platform {
    override val name: String = "Java ${System.getProperty("java.version")}"
    override val version: String = "0"
}

actual fun getPlatform(): Platform = JVMPlatform()