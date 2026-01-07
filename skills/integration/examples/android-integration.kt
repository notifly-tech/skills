// Android Notifly SDK 연동 예시 (Kotlin)
//
// 단일 기준(Source of Truth):
// - 문서: https://docs.notifly.tech/ko/developer-guide/android-sdk.md
// - 공식 예시: https://github.com/team-michael/notifly-android-sdk
//
// 핵심 포인트:
// - JitPack 저장소 추가
// - 의존성 추가: implementation 'com.github.team-michael:notifly-android-sdk:<latest>'
// - Application.onCreate에서 초기화

package com.example.app

import android.app.Application
import tech.notifly.Notifly

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        // 공식 문서 예시(Kotlin):
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