#FROM openjdk:8-jdk-alpine
FROM adoptopenjdk:8-jdk-hotspot-bionic
EXPOSE 8080
ARG JAR_FILE=target/*.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
