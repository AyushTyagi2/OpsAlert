package com.opsalert.monitoring.simulator

import com.opsalert.monitoring.dto.MonitoringDTO
import com.opsalert.monitoring.publisher.MonitoringPublisher
import jakarta.annotation.PostConstruct
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component

@Component
class MonitoringSimulator(private val publisher: MonitoringPublisher){
    private val events = listOf(
        "CPU usage exceeded 85%",
        "Incident INC-101 triggered",
        "Notification service degraded",
        "Database latency increased",
        "System recovered successfully"
    )
    
    @Scheduled(fixedRate = 5000)
    fun simulateMonitoringEvent(){
        val event = MonitoringDTO(
            type = "monitoring",
            severity = listOf("INFO", "WARN", "ERROR").random(),
            message = events.random()
        )
        
        publisher.publish(event)
    }
}