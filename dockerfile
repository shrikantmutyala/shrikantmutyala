# ┌────────── Build Stage ──────────┐
FROM maven:3.8.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy Maven wrapper and config
COPY mvnw ./
COPY .mvn/ .mvn
COPY pom.xml ./

# Ensure wrapper is executable
RUN chmod +x mvnw

# Pre-fetch dependencies offline
RUN ./mvnw dependency:go-offline -B

# Copy source code and build
COPY src/ src/
RUN ./mvnw package -DskipTests

# ┌────────── Runtime Stage ──────────┐
FROM eclipse-temurin:17-jdk-alpine AS runtime
WORKDIR /app

# Copy your built JAR (ensures exact name is kept)
COPY --from=builder /app/target/shrikantmutyala-0.0.1-SNAPSHOT.jar app.jar

# Expose port and launch app
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
