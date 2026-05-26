# ── Stage 1: Build ────────────────────────────────────────────
FROM eclipse-temurin:21-jdk-alpine AS builder
WORKDIR /src

COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN ./mvnw dependency:go-offline -q

COPY src ./src
RUN ./mvnw package -DskipTests -q

# ── Stage 2: Runtime (JRE only, lean) ─────────────────────────
FROM eclipse-temurin:21-jre-alpine AS runtime
WORKDIR /app

ENV SERVER_PORT=<<PORT>> \
    JAVA_OPTS="-XX:MaxRAMPercentage=75.0"

# Non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY --from=builder --chown=appuser:appgroup /src/target/*.jar app.jar

EXPOSE <<PORT>>
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:<<PORT>>/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
