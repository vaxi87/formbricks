package com.formbricks.formbrickssdk.api

import okhttp3.Cache
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.io.File
import java.util.concurrent.TimeUnit

class FormbricksRetrofitBuilder(private val baseUrl: String, private val loggingEnabled: Boolean, cacheDir: File) {
    private val cache: Cache

    init {
        val apiCacheDir = File(cacheDir.absolutePath, "formbricks_cache")
        cache = Cache(apiCacheDir, CACHE_SIZE)
    }

    fun getBuilder(): Retrofit.Builder {
        val clientBuilder = OkHttpClient.Builder()
            .connectTimeout(CONNECT_TIMEOUT_MS.toLong(), TimeUnit.MILLISECONDS)
            .readTimeout(READ_TIMEOUT_MS.toLong(), TimeUnit.MILLISECONDS)
            .followSslRedirects(true)
            .cache(cache)
        if (loggingEnabled) {
            val logging = HttpLoggingInterceptor()
            logging.setLevel(HttpLoggingInterceptor.Level.BODY)
            clientBuilder.addInterceptor(logging)
        }

        return Retrofit.Builder()
            .baseUrl(baseUrl)
            .addConverterFactory(GsonConverterFactory.create())
            .client(clientBuilder.build())
    }

    companion object {
        private const val CONNECT_TIMEOUT_MS = 30 * 1000 // 30 seconds
        private const val READ_TIMEOUT_MS = 30 * 1000 // 30 seconds
        private const val CACHE_SIZE = (10 * 1024 * 1024).toLong() // 10MB
    }
}