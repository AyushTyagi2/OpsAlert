package com.opsalert.incident.dto

import java.time.OffsetDateTime
import java.util.UUID

data class IncidentRequest(
    val id: UUID,

    val title: String? = null,

    val description: String? = null,

    val severity: String? = null,

    val status: String? = null,

    val createdAt: OffsetDateTime = OffsetDateTime.now(),
)