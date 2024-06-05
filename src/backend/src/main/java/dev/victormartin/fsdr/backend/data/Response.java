package dev.victormartin.fsdr.backend.data;

import jakarta.annotation.Nonnull;
import jakarta.persistence.*;

import java.util.Objects;

@Entity
@Table(name = "Responses")
public class Response {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    String status;

    String region;

    String errorMessage;

    @OneToOne(fetch = FetchType.EAGER) @Nonnull
    Request request;

    public Response() {}

    public Response(String status, String region, String errorMessage, Request request) {
        this.status = status;
        this.region = region;
        this.errorMessage = errorMessage;
        this.request = request;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Response response = (Response) o;
        return Objects.equals(id, response.id) && Objects.equals(status, response.status) && Objects.equals(region, response.region) && Objects.equals(errorMessage, response.errorMessage) && Objects.equals(request, response.request);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, status, region, errorMessage, request);
    }

    public Long getId() {
        return id;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    @Nonnull
    public Request getRequest() {
        return request;
    }

    public void setRequest(@Nonnull Request request) {
        this.request = request;
    }
}
