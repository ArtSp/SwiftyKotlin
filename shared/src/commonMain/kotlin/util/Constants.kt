package util

sealed class Constants {
    companion object {
        const val SERVER_PORT = 8080
        const val BASE_URL = "http://127.0.0.1"

    }

    sealed class Path {
        companion object {
            const val GET_VERSION = "/serverVersion"
        }
    }
}