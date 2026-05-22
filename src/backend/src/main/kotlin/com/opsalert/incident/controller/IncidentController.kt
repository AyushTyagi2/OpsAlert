package com.opsalert.incident.controller

import com.opsalert.incident.dto.CreateIncidentDTO
import com.opsalert.incident.dto.IncidentRequest
import com.opsalert.incident.service.IncidentService
import jakarta.validation.Valid
import  org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*


@CrossOrigin(origins = ["http://localhost:3000"])
@RestController
@RequestMapping("/api/v1/incidents")
class IncidentController(
    private val incidentService: IncidentService
) {
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun createIncident(@Valid @RequestBody request: CreateIncidentDTO): IncidentRequest {
        return incidentService.createIncident(request)
    }

    @GetMapping
    fun getAllIncidents(): List<IncidentRequest> {
        return incidentService.getAllIncidents()
    }
}