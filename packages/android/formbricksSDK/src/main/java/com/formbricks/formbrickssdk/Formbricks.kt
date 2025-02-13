package com.formbricks.formbrickssdk

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.annotation.Keep
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.fragment.app.FragmentManager
import com.formbricks.formbrickssdk.api.FormbricksApi
import com.formbricks.formbrickssdk.helper.FormbricksConfig
import com.formbricks.formbrickssdk.webview.FormbricksFragment
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Keep
object Formbricks {
    private lateinit var applicationContext: Context

    internal lateinit var environmentId: String
    internal lateinit var appUrl: String
    internal var loggingEnabled: Boolean = true
    internal var fragmentManager: FragmentManager? = null

    fun setup(context: Context, config: FormbricksConfig) {
        applicationContext = context

        appUrl = config.appUrl
        environmentId = config.environmentId
        loggingEnabled = config.loggingEnabled
        fragmentManager = config.fragmentManager

        FormbricksApi.initialize(context.cacheDir)

        CoroutineScope(Dispatchers.IO).launch {
            FormbricksApi.getEnvironmentState()
        }

        // TODO: show a window from the sdk

        // TODO: local storage handler, survey manager, refresh survey
        // TODO: load a survey to a html
        // TODO: handle javascript commands

        // TODO: error handling
        // TODO: create public methods
        // TODO: logger

        Log.v("FormbricksSDK", "TEST")
    }

    fun setFragmentManager(fragmentManager: FragmentManager) {
        this.fragmentManager = fragmentManager
    }

    fun show() {
        fragmentManager?.let {
            FormbricksFragment.show(it)
        } // TODO: handle if not set
    }
}