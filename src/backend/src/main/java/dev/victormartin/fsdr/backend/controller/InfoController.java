package dev.victormartin.fsdr.backend.controller;

import dev.victormartin.fsdr.backend.dao.Request;
import dev.victormartin.fsdr.backend.dao.Response;
import dev.victormartin.fsdr.backend.service.RunInfoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
public class InfoController {
    Logger log = LoggerFactory.getLogger(InfoController.class);

    @Autowired
    RunInfoService runInfoService;

    @PostMapping("/api/info")
    public Response postInfo(@RequestBody Request request) {
        log.info("POST /api/info: ID " + request.id() + "; Creation: "  + request.creationTimestamp());
        String status = "ok";
        String region = runInfoService.getRegion();
        String errorMessage = "";
        Response response = new Response(
                request.id(),
                status,
                request.creationTimestamp(),
                region,
                errorMessage);
        return response;
    }
}
