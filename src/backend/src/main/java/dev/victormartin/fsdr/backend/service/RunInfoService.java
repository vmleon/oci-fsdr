package dev.victormartin.fsdr.backend.service;

import org.springframework.stereotype.Service;

@Service
public class RunInfoService {
    public String getRegion() {
        return "local";
    }

    public String getAvailabilityDomain() {
        return "local";
    }
}
