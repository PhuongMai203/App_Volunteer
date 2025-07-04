plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.company.help_connect"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.company.help_connect"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    signingConfigs {
        create("release") {
            storeFile = file("D:/help_connect/my-release-key.jks")
            storePassword = "102003"
            keyAlias = "my-key-alias"
            keyPassword = "102003"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // 🔁 Đổi về Java 11 để đồng bộ với các thư viện Flutter hiện tại
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

    }

    kotlinOptions {
        jvmTarget = "11"
    }

    ndkVersion = "27.0.12077973"
}

flutter {
    source = "../.."
}

repositories {
    google()
    mavenCentral()
}

dependencies {
    implementation("com.google.firebase:firebase-firestore-ktx:25.1.4")
    implementation("com.google.firebase:firebase-common-ktx:21.0.0")
    implementation(platform("com.google.firebase:firebase-bom:33.13.0"))

    // Facebook SDK
    implementation("com.facebook.android:facebook-android-sdk:18.0.3")

    // Nếu có thư viện .aar tự thêm
    implementation(fileTree(mapOf("dir" to "libs", "include" to listOf("*.aar"))))

    // Các thư viện HTTP và mã hóa
    implementation("com.squareup.okhttp3:okhttp:4.6.0")
    implementation("commons-codec:commons-codec:1.14")
    implementation ("com.google.firebase:firebase-appcheck-playintegrity")
    implementation ("com.google.firebase:firebase-appcheck-debug") // Chỉ debug
    implementation ("com.google.android.gms:play-services-base:18.4.0")
    implementation ("com.google.android.gms:play-services-basement:18.4.0")
    implementation ("com.google.android.gms:play-services-tasks:18.1.0")
}
