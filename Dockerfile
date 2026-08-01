# Этап 1: Сборка приложения с помощью Gradle
FROM gradle:8.5-jdk17 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
RUN ./gradlew :app:jar --no-daemon -x test

# Этап 2: Запуск готового приложения на чистой Java
FROM openjdk:17-slim
EXPOSE 8080
WORKDIR /app

# Копируем собранный JAR-файл
COPY --from=build /home/gradle/src/app/build/libs/app.jar /app/grain_king.jar

# Запуск бота
CMD ["java", "-jar", "/app/grain_king.jar"]
