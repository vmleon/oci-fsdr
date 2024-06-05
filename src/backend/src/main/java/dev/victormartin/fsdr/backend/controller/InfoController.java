package dev.victormartin.fsdr.backend.controller;

import dev.victormartin.fsdr.backend.dao.RequestDao;
import dev.victormartin.fsdr.backend.dao.ResponseDao;
import dev.victormartin.fsdr.backend.data.Request;
import dev.victormartin.fsdr.backend.data.RequestRepository;
import dev.victormartin.fsdr.backend.data.Response;
import dev.victormartin.fsdr.backend.data.ResponseRepository;
import dev.victormartin.fsdr.backend.service.RunInfoService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InfoController {
    Logger log = LoggerFactory.getLogger(InfoController.class);

    @Autowired
    RunInfoService runInfoService;

    @Autowired
    RequestRepository requestRepository;

    @Autowired
    ResponseRepository responseRepository;

    @PostMapping("/api/info")
    public ResponseDao postInfo(@RequestBody RequestDao requestDao) {
        log.info("POST /api/info: ID " + requestDao.id() + "; Creation: "  + requestDao.creationTimestamp());
        Request request = new Request(requestDao.id(), requestDao.creationTimestamp());
        requestRepository.save(request);
        String status = "ok";
        String region = runInfoService.getRegion();
        String errorMessage = "";
        ResponseDao responseDao = new ResponseDao(
                requestDao.id(),
                status,
                requestDao.creationTimestamp(),
                region,
                errorMessage);
        Response response = new Response(status, region, errorMessage, request);
        responseRepository.save(response);
        return responseDao;
    }
}
