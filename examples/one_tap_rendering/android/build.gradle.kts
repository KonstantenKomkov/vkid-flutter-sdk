allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://nexus-external.vkteam.ru/repository/maven/")
            content { includeGroup("ru.ok.tracer") }
        }
        maven { url = uri("https://nexus-external.vkteam.ru/repository/vkid-sdk-android/") }
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
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
