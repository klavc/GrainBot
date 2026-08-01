# Шаг 1: Сборка Kotlin-приложения с помощью Gradle
FROM gradle:8.5-jdk17 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
# Принудительно выдаем права на выполнение скрипту gradlew
RUN chmod +x ./gradlew
RUN ./gradlew build --no-daemon

# Шаг 2: Стабильный запуск на базе Eclipse Temurin Java 17
FROM eclipse-temurin:17-jre-alpine
EXPOSE 8080
COPY --from=build /home/gradle/src/app/build/libs/*.jar /app/bot.jar
ENTRYPOINT ["java", "-jar", "/app/bot.jar"]
