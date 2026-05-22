package com.opsalert.incident.service

import com.opsalert.incident.dto.CreateIncidentDTO
import com.opsalert.incident.dto.IncidentRequest
import com.opsalert.incident.entity.IncidentEntity
import com.opsalert.incident.repository.IncidentRepository
import org.springframework.stereotype.Service

@Service
class IncidentService(
    private val incidentRepository: IncidentRepository
) {
    fun createIncident(request : CreateIncidentDTO): IncidentRequest{
        val incident = IncidentEntity(
            title = request.title,
            description = request.description,
            severity = request.severity,
            status = "OPEN",
        )
        val saved = incidentRepository.save(incident)

        return IncidentRequest(
            id = saved.id,
            title = saved.title,
            description = saved.description,
            severity = saved.severity,
            status = saved.status,
            createdAt = saved.createdAt,
        )
    }

    fun getAllIncidents(): List<IncidentRequest> {
        return incidentRepository.findAll().map { 
            IncidentRequest(
                id = it.id,
                title = it.title,
                description = it.description,
                severity = it.severity,
                status = it.status,
                createdAt = it.createdAt,
            )
        }
    }
}
