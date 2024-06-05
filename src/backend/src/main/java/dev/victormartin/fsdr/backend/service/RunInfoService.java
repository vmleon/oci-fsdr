package dev.victormartin.fsdr.backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class RunInfoService {

    @Value("${oraclecloud.region-name}")
    String regionName;

    public String getRegion() {
        return regionName;
    }
}
