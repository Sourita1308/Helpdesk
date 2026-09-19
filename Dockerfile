# ==============================================================================
# HelpDesk Lite - Production Multi-Stage Dockerfile
# Compatible with Render, Railway, Fly.io, AWS App Runner, Cloud Run, and VPS
# ==============================================================================

# --- Stage 1: Build ---
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /build

# Cache maven dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# Copy source code and build war
COPY src ./src
RUN mvn clean package -DskipTests -B

# --- Stage 2: Runtime ---
FROM tomcat:10.1-jdk17-temurin-jammy

LABEL maintainer="HelpDesk Lite"
LABEL description="Internal IT Ticketing & Asset Tracker"

# Clean default Tomcat welcome apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR as ROOT application
COPY --from=builder /build/target/helpdesk-lite.war /usr/local/tomcat/webapps/ROOT.war

# Default HTTP Port
ENV PORT=8080
EXPOSE 8080

# Dynamically bind to $PORT for cloud platforms (Render, Railway, Fly.io, Heroku)
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/g\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
