// Android Notifly SDK Integration Example (Kotlin)
//
// Source of truth:
// - Docs: https://docs.notifly.tech/ko/developer-guide/android-sdk.md
// - Official example: https://github.com/team-michael/notifly-android-sdk
//
// Key points:
// - Add JitPack repository
// - Add dependency: implementation 'com.github.team-michael:notifly-android-sdk:<latest>'
// - Initialize in Application.onCreate

package com.example.app

import android.app.Application
import tech.notifly.Notifly

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // Official doc example (Kotlin):
        // https://docs.notifly.tech/ko/developer-guide/android-sdk.md
        Notifly.initialize(
            applicationContext,
            NOTIFLY_PROJECT_ID,
            BuildConfig.NOTIFLY_USERNAME,
            BuildConfig.NOTIFLY_PASSWORD
        )
    }
}

// AndroidManifest.xml:
// <application
//   android:name=".MainApplication"
//   ...
// />
//
// build.gradle (Module: app):
// android {
//   defaultConfig {
//     buildConfigField("String", "NOTIFLY_PROJECT_ID", "\"YOUR_PROJECT_ID\"")
//     buildConfigField("String", "NOTIFLY_USERNAME", "\"YOUR_USERNAME\"")
//     buildConfigField("String", "NOTIFLY_PASSWORD", "\"YOUR_PASSWORD\"")
//   }
// }