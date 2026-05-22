package com.opsalert.incident.dto

import jakarta.validation.constraints.NotBlank

data class CreateIncidentDTO(

    @field:NotBlank(message = "Title is required")
    val title: String,

    val description: String? = null,

    @field:NotBlank(message = "Severity is required")
    val severity: String,
)