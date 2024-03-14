package util

sealed class Constants {
    companion object {
        private const val SERVER_IP = "192.168.8.188"
        private const val SERVER_PORT = 8080
        const val BASE_URL = "http://$SERVER_IP:$SERVER_PORT"
    }

    sealed class Path {
        companion object {
            const val GET_VERSION = "/serverVersion"
        }
    }
}