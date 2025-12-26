# Stage 1: Build with Maven
FROM maven:3.8-jdk-8 AS builder
COPY . /usr/src/easybuggy/
WORKDIR /usr/src/easybuggy/
RUN mvn -B package

# Stage 2: Runtime
FROM openjdk:17-slim
COPY --from=builder /usr/src/easybuggy/target/easybuggy.jar /easybuggy.jar
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Run the application
CMD ["/start.sh"]
