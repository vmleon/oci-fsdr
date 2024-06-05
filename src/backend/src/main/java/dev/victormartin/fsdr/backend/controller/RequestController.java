package dev.victormartin.fsdr.backend.controller;

import dev.victormartin.fsdr.backend.data.Request;
import dev.victormartin.fsdr.backend.data.RequestRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class RequestController {
    Logger log = LoggerFactory.getLogger(RequestController.class);

    @Autowired
    RequestRepository requestRepository;

    @GetMapping("/api/request")
    public List<Request> getAllRequests() {
        log.info("GET /api/request");
        return requestRepository.findAll();
    }
}
