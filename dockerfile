# Build stage
FROM maven:3.8.6-jdk-17 AS builder
WORKDIR /app
COPY pom.xml mvnw ./
RUN ./mvnw dependency:go-offline -B
COPY src src
RUN ./mvnw package -DskipTests

# Run stage
FROM openjdk:17-alpine
COPY --from=builder /app/target/*.jar app.jar
ENTRYPOINT ["java","-jar","/shrikantmutyala-0.0.1-SNAPSHOT.jar"]
EXPOSE 8080
