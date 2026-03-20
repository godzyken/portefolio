import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.godzy.portefolio"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.godzy.portefolio"
        minSdk = 25
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val props = Properties().apply {
            val f = rootProject.file("local.properties")
            if (f.exists()) load(FileInputStream(f))
        }
        buildConfigField("String", "SENDGRID_KEY", "\"${props["SENDGRID_KEY"] ?: ""}\"")
        buildConfigField("String", "SRC_MAIL",     "\"${props["SRC_MAIL"]     ?: ""}\"")
        buildConfigField("String", "DEST_MAIL",    "\"${props["DEST_MAIL"]    ?: ""}\"")

        signingConfig = signingConfigs.getByName("debug")
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.17.0")
}

flutter {
    source = "../.."
}
