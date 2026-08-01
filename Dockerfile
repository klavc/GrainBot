# Этап 1: Сборка приложения с помощью Gradle
FROM gradle:8.5-jdk17 AS build
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src

# Принудительно даем права на выполнение прямо внутри Docker
RUN chmod +x gradlew

# Запускаем сборку
RUN ./gradlew :app:jar --no-daemon -x test

# Этап 2: Запуск готового приложения на стабильной Java
FROM eclipse-temurin:17-jre-alpine
EXPOSE 8080
WORKDIR /app

# Копируем собранный JAR-файл
COPY --from=build /home/gradle/src/app/build/libs/app.jar /app/grain_king.jar

# Запуск бота (ооооо)
CMD ["java", "-jar", "/app/grain_king.jar"]
