FROM --platform=linux/amd64 container-registry.oracle.com/java/jdk-no-fee-term:21-oraclelinux8 as build

RUN mkdir /opt/backend
COPY . /opt/backend
WORKDIR /opt/backend
RUN ./gradlew clean bootJar

FROM --platform=linux/amd64 container-registry.oracle.com/java/jdk-no-fee-term:21-oraclelinux8

VOLUME /tmp
COPY --from=build /opt/backend/build/libs/*.jar /tmp/
RUN mkdir /app
RUN mv /tmp/backend*.jar /app/backend.jar

ENTRYPOINT ["java","-jar","/app/backend.jar"]