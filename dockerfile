# ╔════════════════════════╗
# ║ 1. Build stage         ║
# ╚════════════════════════╝
FROM maven:3.8.6-eclipse-temurin-17 AS builder
WORKDIR /app

# 1. Copy wrapper and project files
COPY mvnw ./
COPY .mvn/ .mvn
COPY pom.xml ./

# 2. Make mvnw executable (and optionally fix Windows CRLF; requires dos2unix)
RUN chmod +x mvnw

# 3. Pre-fetch dependencies offline
RUN ./mvnw dependency:go-offline -B

# 4. Copy source code and package
COPY src/ src/
RUN ./mvnw package -DskipTests

# ╔════════════════════════╗
# ║ 2. Run stage           ║
# ╚════════════════════════╝
FROM eclipse-temurin:17-jdk-alpine AS runtime
WORKDIR /app

# 5. Copy the final JAR and rename it to app.jar
COPY --from=builder /app/target/*.jar app.jar

# 6. Expose port and define entrypoint
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
