import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.contruttore"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // Application ID deve corresponder ao package_name no google-services.json
        applicationId = "com.example.contruttore"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion  // Android 5.0 - Compatível com 99% dos dispositivos
        targetSdk = 33  // Android 13 - Versão estável e amplamente testada
        
        // Version code dinâmico baseado no pubspec.yaml
        // Formato: MAJOR * 10000 + MINOR * 100 + PATCH
        // Exemplo: 1.1.0 = 10100
        versionCode = flutter.versionCode ?: 10100
        versionName = flutter.versionName ?: "1.1.0"
        
        // Configurações adicionais para garantir compatibilidade
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                
                val keystorePath = keystoreProperties.getProperty("storeFile")
                val keystoreFile = file(keystorePath)
                
                // Só configura se o arquivo keystore realmente existir
                if (keystoreFile.exists()) {
                    storeFile = keystoreFile
                    storePassword = keystoreProperties.getProperty("storePassword")
                    keyAlias = keystoreProperties.getProperty("keyAlias")
                    keyPassword = keystoreProperties.getProperty("keyPassword")
                }
            }
        }
    }

    buildTypes {
        release {
            // Só assina se o keystore existir
            val keystorePropertiesFile = rootProject.file("key.properties")
            var shouldSign = false
            
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                val keystorePath = keystoreProperties.getProperty("storeFile")
                shouldSign = file(keystorePath).exists()
            }
            
            if (shouldSign) {
                signingConfig = signingConfigs.getByName("release")
            }
            
            // Desabilitar minify para evitar problemas de inicialização
            isMinifyEnabled = false
            isShrinkResources = false
            
            // Manter nomes de classes para debug
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        debug {
            // Debug sempre sem assinatura
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}
