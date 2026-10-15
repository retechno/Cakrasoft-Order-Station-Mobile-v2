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
// Plugin lama (mis. bluetooth_print 4.3) belum mendeklarasikan `namespace`
// yang diwajibkan AGP 8. Isi dari atribut package di AndroidManifest plugin.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            val current = androidExt.javaClass.getMethod("getNamespace").invoke(androidExt)
            if (current == null) {
                val manifest = file("src/main/AndroidManifest.xml")
                if (manifest.exists()) {
                    val pkg = Regex("package=\"([^\"]+)\"")
                        .find(manifest.readText())?.groupValues?.get(1)
                    if (pkg != null) {
                        androidExt.javaClass
                            .getMethod("setNamespace", String::class.java)
                            .invoke(androidExt, pkg)
                    }
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
