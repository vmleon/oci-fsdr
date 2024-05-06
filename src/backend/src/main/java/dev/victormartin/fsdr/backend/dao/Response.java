package dev.victormartin.fsdr.backend.dao;

import java.util.Date;

public record Response(
        String id,
        String status,
        Date creationTimestamp,
        String region,
        String errorMessage
    ) {
}
