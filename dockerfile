# ┌───────────────────┐
# │ 1. Build stage    │
# └───────────────────┘
FROM maven:3.8.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy wrapper files and ensure proper permission + Linux EOL
COPY mvnw ./
COPY .mvn/ .mvn
COPY pom.xml ./

# Install dos2unix, convert line endings, make mvnw executable
RUN apt-get update && apt-get install -y dos2unix \
    && dos2unix mvnw \
    && chmod +x mvnw

# Resolve dependencies offline
RUN ./mvnw dependency:go-offline -B

# Copy source and package JAR
COPY src/ src/
RUN ./mvnw package -DskipTests

# ┌───────────────────┐
# │ 2. Run stage      │
# └───────────────────┘
FROM eclipse-temurin:17-jdk-alpine
WORKDIR /app

# Copy packaged JAR and rename to app.jar
COPY --from=builder /app/target/*.jar app.jar

# Define runtime startup
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
EXPOSE 8080
