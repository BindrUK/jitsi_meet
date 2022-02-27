
package com.gunschu.jitsi_meet

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.TextView
import io.flutter.plugin.platform.PlatformView
import java.net.URL
import android.util.Log


internal class NativeView(activity: Activity, context: Context, id: Int, creationParams: Map<String?, Any?>?) : PlatformView {
    private val jitsiView: RNJitsiMeetView

    override fun getView(): View {
        return jitsiView
    }

    override fun dispose() {
        jitsiView.leave()
    }

    init {
        val userInfo = RNJitsiMeetUserInfo()
        userInfo.displayName = creationParams?.get("userDisplayName")?.toString()
        userInfo.email = creationParams?.get("userEmail")?.toString()
        if (creationParams?.get("userAvatarURL") != null) {
            userInfo.avatar = URL(creationParams?.get("userAvatarURL")?.toString())
        }
        val optionsBuilder = RNJitsiMeetConferenceOptions.Builder()
        val audioMuted: Boolean = true
        val videoMuted: Boolean = true
        val featureFlags = creationParams?.get("featureFlags")

        optionsBuilder
            .setServerURL(URL("https://meet.jit.si"))
            .setRoom(creationParams?.get("room")?.toString())
            .setSubject(creationParams?.get("subject")?.toString())
            .setAudioMuted(audioMuted)
            .setVideoMuted(videoMuted)
            .setUserInfo(userInfo)
            .setFeatureFlag("chat.enabled",false)
            .setFeatureFlag("pip.enabled", false)
            .setFeatureFlag("tile-view.enabled", true)
            .setFeatureFlag("audio.mute.enabled", false)
            .setFeatureFlag("overflow-menu.enabled", false)


        val options = optionsBuilder.build()
        val view = RNJitsiMeetView(activity)
        view.join(options)

        jitsiView = view
    }
}

