plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val flutterVersionCode = (project.findProperty("flutter.versionCode") as? String) ?: "1"
val flutterVersionName = (project.findProperty("flutter.versionName") as? String) ?: "1.0"

android {
    namespace = "com.example.chakri_info"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ১. এখানে coreLibraryDesugaring এনাবল করা হলো
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.chakri_info"
        minSdk = flutter.minSdkVersion // অন্তত ২১ রাখা ভালো নোটিফিকেশনের জন্য
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        multiDexEnabled = true
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
    // ২. এই লাইনটি অবশ্যই যোগ করতে হবে ডেসুগারিং লাইব্রেরির জন্য
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
