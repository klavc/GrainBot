# Шаг 1: Сборка приложения на базе Java 17
FROM gradle:8.5-jdk17 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN ./gradlew build --no-daemon

# Шаг 2: Запуск готового бота
FROM openjdk:17-slim
EXPOSE 8080
COPY --from=build /home/gradle/src/app/build/libs/*.jar /app/bot.jar
ENTRYPOINT ["java", "-jar", "/app/bot.jar"]
