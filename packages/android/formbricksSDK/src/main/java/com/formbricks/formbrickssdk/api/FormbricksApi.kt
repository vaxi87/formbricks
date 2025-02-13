package com.formbricks.formbrickssdk.api

import com.formbricks.formbrickssdk.Formbricks
import com.formbricks.formbrickssdk.model.environment.EnvironmentDataHolder
import com.formbricks.formbrickssdk.network.FormbricksApiService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

object FormbricksApi {
    private val service = FormbricksApiService()

    fun initialize() {
        service.initialize(
            appUrl = Formbricks.appUrl,
            isLoggingEnabled = Formbricks.loggingEnabled
        )
    }

    suspend fun getEnvironmentState(): Result<EnvironmentDataHolder> = withContext(Dispatchers.IO) {
        try {
            val response = service.getEnvironmentStateObject(Formbricks.environmentId)
            val result = response.getOrThrow()
            Result.success(result)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    // TODO: post response

}