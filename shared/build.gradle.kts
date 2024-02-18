val coroutinesVersion = "1.7.3"
val ktorVersion = "2.3.7"
val sqlDelightVersion = "1.5.5"
val dateTimeVersion = "0.4.1"

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidLibrary)
    kotlin("plugin.serialization").version("1.9.22")
    id("com.squareup.sqldelight").version("1.5.5")
}

kotlin {
    androidTarget {
        compilations.all {
            kotlinOptions {
                jvmTarget = "1.8"
            }
        }
    }
    
    listOf(
        iosX64(),
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = "Shared"
            isStatic = true
        }
    }
    
    sourceSets {
       commonMain.dependencies {
           implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$coroutinesVersion")
           implementation("io.ktor:ktor-client-core:$ktorVersion")
           implementation("io.ktor:ktor-client-content-negotiation:$ktorVersion")
           implementation("io.ktor:ktor-serialization-kotlinx-json:$ktorVersion")
           implementation("com.squareup.sqldelight:runtime:$sqlDelightVersion")
           implementation("org.jetbrains.kotlinx:kotlinx-datetime:$dateTimeVersion")
       }
        androidMain.dependencies {
            implementation("io.ktor:ktor-client-android:$ktorVersion")
            implementation("com.squareup.sqldelight:android-driver:$sqlDelightVersion")
        }
        iosMain.dependencies {
            implementation("io.ktor:ktor-client-darwin:$ktorVersion")
            implementation("com.squareup.sqldelight:native-driver:$sqlDelightVersion")
        }
    }
}

android {
    namespace = "com.civitta.swiftykotlin.shared"
    compileSdk = libs.versions.android.compileSdk.get().toInt()
    defaultConfig {
        minSdk = libs.versions.android.minSdk.get().toInt()
    }
}
