allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
    afterEvaluate {
        // Some Flutter plugins (including tesseract_ocr) set Kotlin JVM 17
        // while leaving Android Java compileOptions at 1.8. Keep Android
        // library Java targets aligned with Kotlin to avoid Gradle's target
        // compatibility failure during plugin compilation.
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.compileOptions?.apply {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }
}

subprojects {
    // Keep Java and Kotlin targets aligned across Android plugins. Some plugins
    // (including tesseract_ocr) default Java compilation to 1.8 while using
    // Kotlin 17, which makes Gradle fail with inconsistent JVM targets.
    afterEvaluate {
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_17.toString()
            targetCompatibility = JavaVersion.VERSION_17.toString()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

    buildscript {
        repositories {
            google()
            mavenCentral()
            gradlePluginPortal()
        }
        dependencies {
        }
    }
