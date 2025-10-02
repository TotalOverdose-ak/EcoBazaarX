package com.ecobazaar.backend.controller;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/health")
@CrossOrigin(origins = "*")
public class HealthController {

    @GetMapping
    public String health() {
        return "EcoBazaarX Backend is healthy!";
    }
    
    @GetMapping("/status")
    public String status() {
        return "Status: OK";
    }
}
