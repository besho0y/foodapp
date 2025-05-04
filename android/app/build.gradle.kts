plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Apply the Google services plugin
}

android {
    ndkVersion = "29.0.13113456" // Directly specify the NDK version
    namespace = "com.example.foodapp"
    compileSdk = 35
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

  kotlinOptions {
    jvmTarget = "11"
}


    defaultConfig {
        applicationId = "com.example.foodapp"
        minSdk = 23 // Updated to meet Firebase Auth requirements
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
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

    // TODO: Add the dependencies for other Firebase products you want to use
    // For example:
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}

apply(plugin = "com.google.gms.google-services")
