package com.formbricks.formbrickssdk.manager

import android.content.Context
import android.util.Log
import com.formbricks.formbrickssdk.Formbricks
import com.formbricks.formbrickssdk.api.FormbricksApi
import com.formbricks.formbrickssdk.extensions.guard
import com.formbricks.formbrickssdk.model.environment.EnvironmentDataHolder
import com.formbricks.formbrickssdk.model.environment.expiresAt
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Date
import java.util.Timer
import java.util.TimerTask

object SurveyManager {
    private const val REFRESH_STATE_ON_ERROR_TIMEOUT_IN_MINUTES = 10
    private const val FORMBRICKS_PREFS = "formbricks_prefs"
    private const val PREF_FORMBRICKS_DATA_HOLDER = "formbricksDataHolder"
    private val prefManager by lazy { Formbricks.applicationContext.getSharedPreferences(FORMBRICKS_PREFS, Context.MODE_PRIVATE) }
    private val timer = Timer()

    private var environmentDataHolderJson: String?
        get() {
            return prefManager.getString(PREF_FORMBRICKS_DATA_HOLDER, "")
        }
        set(value) {
            if (null != value) {
                prefManager.edit()
                    .putString(PREF_FORMBRICKS_DATA_HOLDER, value)
                    .apply()
            } else {
                prefManager.edit().remove(PREF_FORMBRICKS_DATA_HOLDER)
                    .apply()
            }
        }

    private var backingEnvironmentDataHolder: EnvironmentDataHolder? = null
    var environmentDataHolder: EnvironmentDataHolder?
        get() {
            if (null != backingEnvironmentDataHolder) {
                return backingEnvironmentDataHolder
            }
            synchronized(this) {
                backingEnvironmentDataHolder = environmentDataHolderJson?.let { json ->
                    try {
                        Gson().fromJson(json, EnvironmentDataHolder::class.java)
                    } catch (e: Exception) {
                        // TODO: error handling
                        null
                    }
                }
                return backingEnvironmentDataHolder
            }
        }
        set(value) {
            synchronized(this) {
                backingEnvironmentDataHolder = value
                environmentDataHolderJson = Gson().toJson(value)
            }
        }

    fun refreshEnvironment() {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                environmentDataHolder = FormbricksApi.getEnvironmentState().getOrThrow()
                startRefreshTimer(environmentDataHolder?.expiresAt())
            } catch (e: Exception) {
                if (Formbricks.loggingEnabled) {
                    Log.e("SurveyManager", "Unable to refresh environment state.", e)
                }
                startErrorTimer()
            }
        }

    }

    fun postResponse() {

    }

    private fun startRefreshTimer(expiresAt: Date?) {
        val date = expiresAt.guard { return }
        timer.schedule(object: TimerTask() {
            override fun run() {
                if (Formbricks.loggingEnabled) {
                    Log.d("SurveyManager", "Refreshing environment state.")
                }
                refreshEnvironment()
            }

        }, date)
    }

    private fun startErrorTimer() {
        val targetDate = Date(System.currentTimeMillis() + 1000 * 60 * REFRESH_STATE_ON_ERROR_TIMEOUT_IN_MINUTES)
        timer.schedule(object: TimerTask() {
            override fun run() {
                if (Formbricks.loggingEnabled) {
                    Log.d("SurveyManager", "Refreshing environment state after an error")
                }
                refreshEnvironment()
            }

        }, targetDate)
    }

}