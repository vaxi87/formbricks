package com.formbricks.formbrickssdk

import android.content.Context
import androidx.annotation.Keep
import androidx.fragment.app.FragmentManager
import com.formbricks.formbrickssdk.api.FormbricksApi
import com.formbricks.formbrickssdk.helper.FormbricksConfig
import com.formbricks.formbrickssdk.manager.SurveyManager
import com.formbricks.formbrickssdk.webview.FormbricksFragment

@Keep
object Formbricks {
    internal lateinit var applicationContext: Context

    internal lateinit var environmentId: String
    internal lateinit var appUrl: String
    internal var loggingEnabled: Boolean = true
    private var fragmentManager: FragmentManager? = null

    fun setup(context: Context, config: FormbricksConfig) {
        applicationContext = context

        appUrl = config.appUrl
        environmentId = config.environmentId
        loggingEnabled = config.loggingEnabled
        fragmentManager = config.fragmentManager

        FormbricksApi.initialize()
        SurveyManager.refreshEnvironment()

        // TODO: error handling and logging
        // TODO: save a response
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