import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload-Schlüssel: android/key.properties (nie committen, siehe store/SCHLUESSEL.md).
// Fehlt die Datei, wird das Release unsigniert gebaut und danach per jarsigner signiert.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) load(FileInputStream(keystorePropertiesFile))
}

// AdMob-App-ID: Umgebungsvariable ADMOB_APP_ID > Gradle-Property admobAppId > Google-Test-ID.
val admobAppId: String =
    System.getenv("ADMOB_APP_ID")?.takeIf { it.isNotBlank() }
        ?: (project.findProperty("admobAppId") as String?)?.takeIf { it.isNotBlank() }
        ?: "ca-app-pub-3940256099942544~3347511713"

android {
    namespace = "com.thinkube.feierabendrechner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Für flutter_local_notifications (geplante Benachrichtigungen).
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.thinkube.feierabendrechner"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobAppId
        // Store-Bundle nur für ARM (Env ARM_ONLY=true, gesetzt in android-bundle.yml).
        // Wichtig: ALLE nativen Bibliotheken filtern – sonst bekäme ein x86_64-Gerät eine
        // Variante ohne Flutter-Engine (nur Plugin-Bibliotheken) und stürzte beim Start ab.
        if (System.getenv("ARM_ONLY") == "true") {
            ndk { abiFilters += listOf("armeabi-v7a", "arm64-v8a") }
        }
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else null
            // Eigene R8-Regeln (u. a. gegen den Start-Absturz durch WorkManager, siehe Datei).
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
