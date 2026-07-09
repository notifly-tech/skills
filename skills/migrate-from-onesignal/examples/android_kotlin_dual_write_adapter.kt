import android.content.Context
import com.onesignal.OneSignal
import tech.notifly.Notifly

/**
 * Small migration seam for OneSignal -> Notifly.
 *
 * In coexist mode, route app-level identity/properties/events through this adapter.
 * In complete mode, remove the OneSignal calls and keep only the Notifly calls.
 */
class OneSignalNotiflyDualWriteAdapter(
    private val context: Context,
) {
    fun initializeNotifly(projectId: String, username: String) {
        Notifly.initialize(
            context.applicationContext,
            projectId,
            username,
            // Compatibility placeholder only. Do not put an API secret in mobile code.
            username,
        )
    }

    fun setUserId(userId: String?) {
        if (userId.isNullOrBlank()) {
            OneSignal.logout()
        } else {
            OneSignal.login(userId)
        }
        Notifly.setUserId(context, userId)
    }

    fun setUserProperties(properties: Map<String, Any?>) {
        val compact = properties.filterValues { it != null }
        if (compact.isEmpty()) return

        // OneSignal tags are string-only. Keep this conversion explicit so campaign
        // owners can review bool/number/timestamp semantics during migration.
        OneSignal.User.addTags(compact.mapValues { (_, value) -> value.toString() })
        Notifly.setUserProperties(context, compact)
    }

    fun trackEvent(
        eventName: String,
        eventParams: Map<String, Any?> = emptyMap(),
        segmentationEventParamKeys: List<String>? = null,
    ) {
        val compact = eventParams.filterValues { it != null }
        OneSignal.User.trackEvent(eventName, compact)
        Notifly.trackEvent(context, eventName, compact, segmentationEventParamKeys)
    }
}
