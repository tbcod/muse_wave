allprojects {
    repositories {
        google()
        mavenCentral()
        maven("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea")
        maven("https://artifact.bytedance.com/repository/pangle")
        maven("https://jfrog.anythinktech.com/artifactory/overseas_sdk")
        maven("https://jfrog.anythinktech.com/artifactory/debugger")
        maven("https://android-sdk.is.com/")
        maven("https://artifactory.bidmachine.io/bidmachine")
        maven("https://repo1.anythinktech.com/android_sdk")
        mavenLocal()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                if (namespace == null) {
                    namespace = group.toString()
                }
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
