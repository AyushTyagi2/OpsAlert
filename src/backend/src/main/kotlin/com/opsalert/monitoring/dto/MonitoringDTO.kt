package com.opsalert.monitoring.dto
import java.time.Instant

data class MonitoringDTO(
    val type:String,
    val severity:String,
    val message:String,
    val timestamp: Instant = Instant.now()
)