package com.opsalert.incident.repository

import com.opsalert.incident.entity.IncidentEntity
import org.springframework.data.jpa.repository.JpaRepository
import java.util.UUID

interface IncidentRepository : JpaRepository<IncidentEntity, UUID> {
    // Custom query methods can be defined here if needed
}