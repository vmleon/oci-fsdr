package dev.victormartin.fsdr.backend.dao;

import java.util.Date;

public record Request(
        String id,
        Date creationTimestamp
    ) {
}
