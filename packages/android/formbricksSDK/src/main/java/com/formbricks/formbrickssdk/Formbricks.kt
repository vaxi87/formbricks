package com.formbricks.formbrickssdk

import android.content.Context
import android.util.Log
import androidx.annotation.Keep
import com.formbricks.formbrickssdk.api.FormbricksApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Keep
object Formbricks {
    internal lateinit var applicationContext: Context

    internal var logLevel: Int = Log.ASSERT + 1
    internal lateinit var environmentId: String
    internal lateinit var appUrl: String

    fun setup(context: Context) {
        environmentId = "cm6ovvfoc000asf0k39wbzc8s"
        appUrl = "http://192.168.0.13:3000"

        FormbricksApi.initialize(context.cacheDir)

        CoroutineScope(Dispatchers.IO).launch {
            val state = FormbricksApi.getEnvironmentState()
            val res = state.getOrNull()
            res
        }

        Log.v("FormbricksSDK", "TEST")
    }
}