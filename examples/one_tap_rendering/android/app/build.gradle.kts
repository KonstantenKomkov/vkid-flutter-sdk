import java.util.Properties

plugins {
    id("com.android.application")
    // Apply Flutter after the Android plugin; AGP 9 provides built-in Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

val vkProperties = Properties().apply {
    rootProject.file("local.properties").inputStream().use { load(it) }
}
val vkClientId = vkProperties.getProperty("VKIDClientID", "")
val vkClientSecret = vkProperties.getProperty("VKIDClientSecret", "")
require(vkClientId.isNotBlank() && vkClientSecret.isNotBlank()) {
    "Set VKIDClientID and VKIDClientSecret in android/local.properties (see README.md)"
}

android {
    namespace = "com.example.vkid.one_tap_rendering"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = vkProperties.getProperty("VKIDApplicationID", "com.example.vkid.one_tap_rendering")
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        manifestPlaceholders += mapOf(
            "VKIDClientID" to vkClientId,
            "VKIDClientSecret" to vkClientSecret,
            "VKIDRedirectHost" to "vk.ru",
            "VKIDRedirectScheme" to "vk$vkClientId",
        )
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (vkProperties.getProperty("VKIDStoreFile") != null) {
            create("registeredApp") {
                storeFile = file(vkProperties.getProperty("VKIDStoreFile"))
                storePassword = vkProperties.getProperty("VKIDStorePassword")
                keyAlias = vkProperties.getProperty("VKIDKeyAlias")
                keyPassword = vkProperties.getProperty("VKIDKeyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Use the locally registered identity when provided, otherwise the debug key.
            signingConfig = signingConfigs.findByName("registeredApp") ?: signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Required at runtime by VK ID Android SDK 2.6.0.
dependencies {
    implementation("ru.ok.tracer:tracer-lite-commons:1.0.0-beta.1")
}
