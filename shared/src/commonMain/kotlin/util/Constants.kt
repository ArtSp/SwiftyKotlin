package util

sealed class Constants {
    companion object {
        const val SERVER_IP = "192.168.8.188"
        const val SERVER_PORT = 8080
        const val BASE_URL = "http://$SERVER_IP:$SERVER_PORT"
    }

    sealed class Path {
        companion object {
            const val GET_VERSION = "/serverVersion"
             const val WS_SERVER_TIME = "/serverTime"
            const val WS_SERVER_CHAT = "/chat" //expected query "name": String
        }
    }
}