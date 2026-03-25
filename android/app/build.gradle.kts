plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Fixed version variables for Flutter with fallback values
val flutterVersionCode = (project.findProperty("flutter.versionCode") as? String) ?: "1"
val flutterVersionName = (project.findProperty("flutter.versionName") as? String) ?: "1.0"

android {
    namespace = "com.example.chakri_info"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Updated to use the recommended string format for jvmTarget
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.chakri_info"

        // Using explicit minSdk 21 for Firebase and modern package compatibility
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName

        // Enabled MultiDex for Firebase compatibility
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
