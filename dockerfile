# ┌────────── Build Stage ────────────────────────
FROM maven:3-eclipse-temurin-17 AS build
WORKDIR /app

# Copy your entire project into the container
COPY . .

# Build the JAR (skip tests for faster deploy)
RUN mvn clean package -DskipTests

# ┌────────── Runtime Stage ──────────────────────
FROM eclipse-temurin:17-jdk-alpine AS runtime
WORKDIR /app

# Copy the generated jar and rename for simplicity
COPY --from=build /app/target/shrikantmutyala-0.0.1-SNAPSHOT.jar shrikantmutyala.jar

# Make sure Render uses the PORT env var
EXPOSE 8080
ENV PORT=8080

# Entrypoint to launch your Spring Boot app
ENTRYPOINT ["java", "-jar", "shrikantmutyala.jar"]
