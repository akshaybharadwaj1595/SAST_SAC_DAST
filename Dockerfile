# Stage 1: Build the project using Maven
FROM maven:3.8.8-openjdk-17 AS builder

# Copy all files and set working directory
COPY . /usr/src/easybuggy/
WORKDIR /usr/src/easybuggy/

# Build the project
RUN mvn -B package -DskipTests

# Stage 2: Create runtime image
FROM eclipse-temurin:17-jdk-slim

# Copy the JAR from the builder stage
COPY --from=builder /usr/src/easybuggy/target/easybuggy.jar /easybuggy.jar

# Expose ports if needed
EXPOSE 8080 9009 7900

# Run the application
CMD ["java", "-XX:MaxMetaspaceSize=128m", "-Xloggc:logs/gc_%p_%t.log", "-Xmx256m", "-XX:MaxDirectMemorySize=90m", "-XX:+UseSerialGC",
     "-XX:+PrintHeapAtGC", "-XX:+PrintGCDetails", "-XX:+PrintGCDateStamps", "-XX:+UseGCLogFileRotation", "-XX:NumberOfGCLogFiles=5",
     "-XX:GCLogFileSize=10M", "-XX:GCTimeLimit=15", "-XX:GCHeapFreeLimit=50", "-XX:+HeapDumpOnOutOfMemoryError", "-XX:HeapDumpPath=logs/",
     "-XX:ErrorFile=logs/hs_err_pid%p.log", "-agentlib:jdwp=transport=dt_socket,server=y,address=9009,suspend=n",
     "-Dderby.stream.error.file=logs/derby.log", "-Dderby.infolog.append=true", "-Dderby.language.logStatementText=true",
     "-Dderby.locks.deadlockTrace=true", "-Dderby.locks.monitor=true", "-Dderby.storage.rowLocking=true",
     "-Dcom.sun.management.jmxremote", "-Dcom.sun.management.jmxremote.port=7900", "-Dcom.sun.management.jmxremote.ssl=false",
     "-Dcom.sun.management.jmxremote.authenticate=false", "-ea", "-jar", "/easybuggy.jar"]
