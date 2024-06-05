package dev.victormartin.fsdr.backend.dao;

import java.util.Date;

public record RequestDao(
        String id,
        Date creationTimestamp
    ) {
}
