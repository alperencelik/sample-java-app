# First stage: build the application with Maven
FROM openjdk:11-jdk-slim AS build
WORKDIR /app
COPY . .
RUN ./mvnw package

# Second stage: run the application
FROM openjdk:11-jre-slim
WORKDIR /app
COPY --from=build /app/target/app-0.0.1-SNAPSHOT.jar .
CMD ["java", "-jar", "app-0.0.1-SNAPSHOT.jar"]

