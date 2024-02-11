package com.civitta.swiftykotlin

import data.remote.models.AppVersionDTO
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import util.Constants
import util.getPlatform

fun main() {
    embeddedServer(Netty, port = Constants.SERVER_PORT, host = "0.0.0.0", module = Application::module)
        .start(wait = true)
}

fun Application.module() {
    routing {
        get(Constants.Path.GET_VERSION) {
            val platform = getPlatform()
            val version = AppVersionDTO(platform.name, platform.version)
            // TODO: Respond with JSON
            call.respondText(version.toString())
        }
    }
}
