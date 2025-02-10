package com.formbricks.formbrickssdk.network

import com.formbricks.formbrickssdk.model.EnvironmentResponse
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Path

interface FormbricksService {

    @GET("$API_PREFIX/client/{environmentId}/environment")
    fun getEnvironmentState(@Path("environmentId") environmentId: String): Call<EnvironmentResponse>

    companion object {
        const val API_PREFIX = "/api/v1"
    }
}