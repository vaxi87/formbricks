package com.formbricks.formbrickssdk.network

import com.formbricks.formbrickssdk.api.FormbricksAPIError
import com.formbricks.formbrickssdk.api.FormbricksRetrofitBuilder
import com.formbricks.formbrickssdk.model.BaseFormbricksResponse
import com.formbricks.formbrickssdk.model.EnvironmentResponse
import com.google.gson.Gson
import retrofit2.Call
import retrofit2.Retrofit
import java.io.File

class FormbricksApiService {

    private lateinit var retrofit: Retrofit

    fun initialize(appUrl: String, cacheDir: File, isLoggingEnabled: Boolean) {
        retrofit = FormbricksRetrofitBuilder(appUrl, isLoggingEnabled, cacheDir)
            .getBuilder()
            .build()
    }

    fun getEnvironmentState(environmentId: String): Result<EnvironmentResponse> {
        return execute {
            retrofit.create(FormbricksService::class.java)
                .getEnvironmentState(environmentId)
        }
    }

    private inline fun <reified T : BaseFormbricksResponse> execute(apiCall: () -> Call<T>): Result<T> {
        val call = apiCall().execute()
        return if (call.isSuccessful) {
            val body = call.body()
            if (body == null) {
                Result.failure(RuntimeException(""))
            } else {
                Result.success(body)
            }
        } else {
            return try {
                val errorResponse = Gson().fromJson(call.errorBody()?.string(), FormbricksAPIError::class.java)
                Result.failure(errorResponse)
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }


}