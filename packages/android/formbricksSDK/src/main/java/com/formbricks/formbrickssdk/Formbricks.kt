package com.formbricks.formbrickssdk

import android.content.Context
import android.util.Log
import androidx.annotation.Keep
import com.formbricks.formbrickssdk.api.FormbricksApi
import com.formbricks.formbrickssdk.helper.FormbricksConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Keep
object Formbricks {
    internal lateinit var applicationContext: Context

    internal lateinit var environmentId: String
    internal lateinit var appUrl: String
    internal var loggingEnabled: Boolean = true

    fun setup(context: Context, config: FormbricksConfig) {
        applicationContext = context

        appUrl = config.appUrl
        environmentId = config.environmentId
        loggingEnabled = config.loggingEnabled

        FormbricksApi.initialize(context.cacheDir)

        CoroutineScope(Dispatchers.IO).launch {
            val state = FormbricksApi.getEnvironmentState()
            val res = state.getOrNull()
            res
        }

        Log.v("FormbricksSDK", "TEST")
    }
}