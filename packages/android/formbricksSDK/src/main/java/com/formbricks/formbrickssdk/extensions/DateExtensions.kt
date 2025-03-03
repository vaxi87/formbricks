package com.formbricks.formbrickssdk.extensions

import com.formbricks.formbrickssdk.model.environment.EnvironmentDataHolder
import com.formbricks.formbrickssdk.model.user.UserState
import com.formbricks.formbrickssdk.model.user.UserStateData
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Date

internal const val dateFormatPattern = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

fun Date.dateString(): String {
    val formatter = DateTimeFormatter.ofPattern(dateFormatPattern)
    return formatter.format(toInstant())
}

fun UserStateData.lastDisplayAt(): Date? {
    lastDisplayAt?.let {
        val formatter = DateTimeFormatter.ofPattern(dateFormatPattern)
        val dateTime = LocalDateTime.parse(it, formatter)
        return Date.from(dateTime.atZone(ZoneId.of("GMT")).toInstant())
    }

    return null
}

fun UserState.expiresAt(): Date? {
    expiresAt?.let {
        val formatter = DateTimeFormatter.ofPattern(dateFormatPattern)
        val dateTime = LocalDateTime.parse(it, formatter)
        return Date.from(dateTime.atZone(ZoneId.of("GMT")).toInstant())
    }

    return null
}

fun EnvironmentDataHolder.expiresAt(): Date? {
    data?.expiresAt?.let {
        val formatter = DateTimeFormatter.ofPattern(dateFormatPattern)
        val dateTime = LocalDateTime.parse(it, formatter)
        return Date.from(dateTime.atZone(ZoneId.of("GMT")).toInstant())
    }

    return null
}