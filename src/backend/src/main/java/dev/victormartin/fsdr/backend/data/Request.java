package dev.victormartin.fsdr.backend.data;

import jakarta.persistence.*;

import java.util.Date;
import java.util.Objects;

@Entity
@Table(name = "Requests")
public class Request {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    String requestId;

    Date requestDate;

    @OneToOne (cascade = CascadeType.ALL, fetch = FetchType.EAGER)
    Response response;

    public Request() {}

    public Request(String requestId, Date requestDate) {
        this.requestDate = requestDate;
        this.requestId = requestId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Request request = (Request) o;
        return Objects.equals(id, request.id) && Objects.equals(requestId, request.requestId) && Objects.equals(requestDate, request.requestDate) && Objects.equals(response, request.response);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, requestId, requestDate, response);
    }

    public Long getId() {
        return id;
    }

    public String getRequestId() {
        return requestId;
    }

    public void setRequestId(String requestId) {
        this.requestId = requestId;
    }

    public Date getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(Date requestDate) {
        this.requestDate = requestDate;
    }

    public Response getResponse() {
        return response;
    }

    public void setResponse(Response response) {
        this.response = response;
    }
}
