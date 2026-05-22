package com.opsalert.incident.entity

import jakarta.persistence.*
import java.time.OffsetDateTime
import java.util.UUID

@Entity
@Table(name = "incidents")

class IncidentEntity(

    @Id
    val id: UUID = UUID.randomUUID(),

    @Column(nullable = false)
    val title:String,

    @Column(columnDefinition = "TEXT")
    val description: String? = null,

    @Column(nullable = false)
    val severity: String,

    @Column(nullable = false)
    val status: String,

    @Column(name = "created_at")
    val createdAt: OffsetDateTime = OffsetDateTime.now(),

    @Column(name = "updated_at")
    val updatedAt: OffsetDateTime = OffsetDateTime.now(),
)