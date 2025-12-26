# Stage 1: Build with Maven
FROM maven:3.8-jdk-8 AS builder
COPY . /usr/src/easybuggy/
WORKDIR /usr/src/easybuggy/
RUN mvn -B package

# Stage 2: Runtime
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# Copy the WAR file from the builder stage
COPY --from=builder /usr/src/easybuggy/target/ROOT.war ./easybuggy.war

# Copy start script
COPY start.sh ./start.sh
RUN chmod +x ./start.sh

# Expose port your app will run on
EXPOSE 8080

# Run the application
CMD ["./start.sh"]
