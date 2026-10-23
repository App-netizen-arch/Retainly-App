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
    // Configure Android libraries when their plugin is applied. An afterEvaluate
    // callback is too late here because evaluationDependsOn(":app") can evaluate
    // the app project before this callback is registered.
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }
}

// Keep Java and Kotlin targets aligned across Android plugins. Some plugins
// (including tesseract_ocr) default Java compilation to 1.8 while using Kotlin 17.
// Apply this after every project has configured its Android compile tasks.
gradle.projectsEvaluated {
    rootProject.subprojects.forEach { subproject ->
        subproject.tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = JavaVersion.VERSION_17.toString()
            targetCompatibility = JavaVersion.VERSION_17.toString()
        }

        // Some Flutter plugins (notably pdfx) still default Kotlin to JVM 11.
        // Match their Kotlin bytecode target to the Java 17 target above to
        // prevent Gradle's inconsistent JVM-target validation from failing.
        subproject.tasks
            .withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>()
            .configureEach {
                if (subproject.name == "tesseract_ocr") {
                    // tesseract_ocr 0.5.0 ships both a Java and Kotlin class with
                    // the same fully qualified name. Its Java source contains the
                    // real extractText/extractHocr implementation; the Kotlin file
                    // is only a platform-version stub. Compile the Java class and
                    // exclude that duplicate Kotlin stub.
                    setSource(
                        project.files(source).asFileTree.matching {
                            exclude("**/TesseractOcrPlugin.kt")
                        }
                    )
                }
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
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
