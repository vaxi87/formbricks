package com.formbricks.formbrickssdk.network

import com.formbricks.formbrickssdk.model.display.PostDisplayBody
import com.formbricks.formbrickssdk.model.display.PostDisplayResponse
import com.formbricks.formbrickssdk.model.response.PostSurveyResponse
import com.formbricks.formbrickssdk.model.response.PostSurveyResponseBody
import com.formbricks.formbrickssdk.model.response.SurveyResponse
import com.formbricks.formbrickssdk.model.response.UpdateSurveyResponseBody
import com.formbricks.formbrickssdk.model.upload.FetchStorageUrlRequestBody
import com.formbricks.formbrickssdk.model.upload.FetchStorageUrlResponse
import com.formbricks.formbrickssdk.model.upload.FileUploadBody
import com.formbricks.formbrickssdk.model.user.PostUserBody
import com.formbricks.formbrickssdk.model.user.UserResponse
import com.formbricks.formbrickssdk.network.FormbricksService.Companion.API_PREFIX
import retrofit2.Call
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.PUT
import retrofit2.http.Path

interface FormbricksService {

    @GET("$API_PREFIX/client/{environmentId}/environment")
    fun getEnvironmentState(@Path("environmentId") environmentId: String): Call<Map<String, Any>>

    @POST("$API_PREFIX/client/{environmentId}/responses")
    fun postSurveyResponse(@Path("environmentId") environmentId: String, @Body body: PostSurveyResponseBody): Call<PostSurveyResponse>

    @PUT("$API_PREFIX/client/{environmentId}/responses/{responseId}")
    fun updateSurveyResponse(@Path("environmentId") environmentId: String, @Path("responseId") responseId: String, @Body body: UpdateSurveyResponseBody): Call<Map<String, Any>>

    @POST("$API_PREFIX/client/{environmentId}/displays")
    fun postDisplay(@Path("environmentId") environmentId: String, @Body body: PostDisplayBody): Call<PostDisplayResponse>

    @PUT("$API_PREFIX/client/{environmentId}/displays/{displayId}")
    fun updateDisplay(@Path("environmentId") environmentId: String, @Path("displayId") displayId: String, @Body body: PostDisplayBody): Call<PostDisplayResponse>

    @POST("$API_PREFIX/client/{environmentId}/user")
    fun postUser(@Path("environmentId") environmentId: String, @Body body: PostUserBody): Call<UserResponse>

    @POST("$API_PREFIX/client/{environmentId}/storage")
    fun fetchStorageUrl(@Path("environmentId") environmentId: String, @Body body: FetchStorageUrlRequestBody): Call<FetchStorageUrlResponse>

    @POST("{path}")
    fun uploadFile(@Path("path") path: String, @Body fileUploadBody: FileUploadBody): Call<Map<String, Any>>

    companion object {
        const val API_PREFIX = "/api/v1"
    }

}