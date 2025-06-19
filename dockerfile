# 📦 1. Build stage
FROM maven:3.8.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy wrapper and dependencies
COPY mvnw ./
COPY .mvn/ .mvn
COPY pom.xml ./
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copy source code and build
COPY src/ src/
RUN ./mvnw package -DskipTests

# 🏃 2. Runtime stage
FROM eclipse-temurin:17-jdk-alpine AS runtime
WORKDIR /app

# Copy the specific jar and rename
COPY --from=builder /app/target/shrikantmutyala-0.0.1-SNAPSHOT.jar shrikantmutyala.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/shrikantmutyala.jar"]
