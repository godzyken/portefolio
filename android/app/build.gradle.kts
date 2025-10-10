import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.godzy.portefolio"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }


    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.godzy.portefolio"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // ─────── Charger local.properties ───────
        val props = Properties().apply {
            val localPropsFile = rootProject.file("local.properties")
            if (localPropsFile.exists()) {
                load(FileInputStream(localPropsFile))
            }
        }

        buildConfigField(
            "String",
            "SENDGRID_KEY",
            "\"${props["SENDGRID_KEY"] ?: ""}\""
        )
        buildConfigField(
            "String",
            "SRC_MAIL",
            "\"${props["SRC_MAIL"] ?: ""}\""
        )
        buildConfigField(
            "String",
            "DEST_MAIL",
            "\"${props["DEST_MAIL"] ?: ""}\""
        )
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
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
    // autres dépendances si besoin
}

// ───── Flutter ─────
flutter {
    source = "../.."
}
