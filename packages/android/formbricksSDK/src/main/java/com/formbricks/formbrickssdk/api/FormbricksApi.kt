package com.formbricks.formbrickssdk.api

import android.util.Log
import com.formbricks.formbrickssdk.Formbricks
import com.formbricks.formbrickssdk.model.EnvironmentResponse
import com.formbricks.formbrickssdk.network.FormbricksApiService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

object FormbricksApi {
    private val service = FormbricksApiService()

    fun initialize(cacheDir: File) {
        val loggingEnabled = Formbricks.logLevel >= Log.VERBOSE
        service.initialize(
            appUrl = Formbricks.appUrl,
            cacheDir = cacheDir,
            isLoggingEnabled = loggingEnabled
        )
    }

    suspend fun getEnvironmentState(): Result<EnvironmentResponse> = withContext(Dispatchers.IO) {
        try {
            val response = service.getEnvironmentState(Formbricks.environmentId)
            val result = response.getOrThrow()
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

}