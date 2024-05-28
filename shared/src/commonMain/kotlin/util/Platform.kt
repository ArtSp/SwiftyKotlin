package util

interface Platform {
    val name: String
    val version: String
    val os: OS
    enum class OS { IOS, ANDROID }
}

expect fun getPlatform(): Platform