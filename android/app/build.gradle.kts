plugins {
    id("com.android.application") 
    id("org.jetbrains.kotlin.android") 
    id("dev.flutter.flutter-plugin-loader") 
}

fun getLocalProperty(propertyName: String): String? { 
    val localProperties = java.util.Properties() 
    val localPropertiesFile = rootProject.file("local.properties") 
    if (localPropertiesFile.exists()) { 
        localPropertiesFile.inputStream().use { inputStream -> 
            localProperties.load(inputStream) 
        } 
    } 
    return localProperties.getProperty(propertyName) 
}

android {
    namespace = "com.example.persiamarkt" 
    compileSdk = 34 
    ndkVersion = "27.0.12077973" // تنظیم ورژن NDK برای رفع هشدار ناسازگاری
    defaultConfig {
        applicationId = "com.example.persiamarkt" 
        minSdk = 21 
        targetSdk = 34 
        versionCode = getLocalProperty("flutter.versionCode")?.toInt() ?: 1 
        versionName = getLocalProperty("flutter.versionName") ?: "1.0.0" 
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner" 
    }

    signingConfigs {
        create("release") {
            // Add your signing config here for release builds
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release") 
            isShrinkResources = true 
            isMinifyEnabled = true 
        }
        debug {
            isShrinkResources = false 
            isMinifyEnabled = false 
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8 
        targetCompatibility = JavaVersion.VERSION_1_8 
    }

    kotlinOptions {
        jvmTarget = "1.8" 
    }
}

flutter {
    source = "../.." 
}