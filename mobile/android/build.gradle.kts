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
    // camera_android_camerax 0.6.x 编译期缺失 androidx.concurrent:concurrent-futures
    // （camera-core 1.5.3 API 引用了 CallbackToFutureAdapter），在插件升级前从应用侧补依赖
    if (project.name == "camera_android_camerax") {
        plugins.withId("com.android.library") {
            dependencies.add(
                "implementation",
                "androidx.concurrent:concurrent-futures:1.2.0",
            )
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
