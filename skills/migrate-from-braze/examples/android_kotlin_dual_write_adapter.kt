package com.example.migration

import android.content.Context
import tech.notifly.Notifly

/**
 * Coexist-mode adapter sketch. Inject Braze lambdas from the existing integration
 * so app code can call one vendor-neutral surface during migration.
 */
class BrazeNotiflyDualWriteAdapter(
    private val context: Context,
    private val brazeChangeUser: ((String?) -> Unit)? = null,
    private val brazeSetUserProperties: ((Map<String, Any?>) -> Unit)? = null,
    private val brazeTrackEvent: ((String, Map<String, Any?>?) -> Unit)? = null,
) {
    fun initializeNotifly(projectId: String, username: String) {
        // password is a legacy placeholder. Do not put a real password/API secret here.
        Notifly.initialize(context.applicationContext, projectId, username, username)
    }

    fun setUserId(userId: String?) {
        brazeChangeUser?.invoke(userId)
        Notifly.setUserId(context, userId)
    }

    fun setUserProperties(properties: Map<String, Any?>) {
        brazeSetUserProperties?.invoke(properties)
        Notifly.setUserProperties(context, properties)
    }

    fun trackEvent(name: String, params: Map<String, Any?>? = null) {
        brazeTrackEvent?.invoke(name, params)
        Notifly.trackEvent(context, name, params)
    }
}
