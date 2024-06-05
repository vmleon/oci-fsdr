package dev.victormartin.fsdr.backend.dao;

import java.util.Date;

public record ResponseDao(
        String id,
        String status,
        Date creationTimestamp,
        String region,
        String errorMessage
    ) {
}
