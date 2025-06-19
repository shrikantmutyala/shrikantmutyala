# ┌──────────────────────────────┐
# │ 1. Build stage               │
# └──────────────────────────────┘
FROM maven:3.8.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy wrapper and project files in the correct order
COPY mvnw ./
COPY .mvn/ .mvn
COPY pom.xml ./

# Ensure wrapper is Unix format (fix Windows CRLF line endings) and executable
RUN apt-get update && apt-get install -y dos2unix \
    && dos2unix mvnw \
    && chmod +x mvnw

# Pre-fetch dependencies
RUN ./mvnw dependency:go-offline -B

# Copy source and build the application
COPY src/ src/
RUN ./mvnw package -DskipTests

# ┌──────────────────────────────┐
# │ 2. Run stage                 │
# └──────────────────────────────┘
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy the built JAR (renamed to app.jar) from build stage
COPY --from=builder /app/target/*.jar app.jar

# Run the app
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
EXPOSE 8080
