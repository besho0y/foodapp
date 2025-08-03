import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.Project
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Apply the Google services plugin
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ndkVersion = "29.0.13113456" // Directly specify the NDK version
    namespace = "com.besho0y.foodapp"
    compileSdk = 35
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

  kotlinOptions {
    jvmTarget = "11"
}

    defaultConfig {
        applicationId = "com.besho0y.foodapp"
        minSdk = 23 // Updated to meet Firebase Auth requirements
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

   signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now,
            // so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))  // Firebase BoM

    // Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")
    
    // Firebase Messaging
    implementation("com.google.firebase:firebase-messaging")

    // TODO: Add the dependencies for other Firebase products you want to use
    // For example:
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.android.play:core-common:2.0.3")

}

apply(plugin = "com.google.gms.google-services")
