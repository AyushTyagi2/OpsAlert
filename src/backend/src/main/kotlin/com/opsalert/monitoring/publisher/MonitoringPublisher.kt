package com.opsalert.monitoring.publisher

import com.opsalert.monitoring.dto.MonitoringDTO
import org.springframework.messaging.simp.SimpMessagingTemplate
import org.springframework.stereotype.Component

@Component
class MonitoringPublisher(private val messagingTemplate : SimpMessagingTemplate){
    fun publish(event: MonitoringDTO){
        messagingTemplate.convertAndSend("/topic/monitoring", event)
    }
}