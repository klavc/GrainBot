# Шаг 1: Используем образ, который на Render гарантированно скачивается
FROM gradle:8.5-jdk17 AS build

# Создаем рабочую папку
WORKDIR /app

# Копируем всё содержимое репозитория
COPY . .

# Переходим прямо к вашему коду
WORKDIR /app/app/src/main/kotlin/org/example

# Скачиваем саму библиотеку Telegram и её сетевые зависимости прямо в папку к коду
RUN apt-get update && apt-get install -y wget && \
    wget https://maven.org && \
    wget https://maven.org && \
    wget https://maven.org && \
    wget https://maven.org

# Скачиваем официальный компилятор Kotlin, чтобы не зависеть от скрытых путей образа
RUN wget https://github.com && \
    unzip kotlin-compiler-1.9.22.zip -d /opt/ && \
    rm kotlin-compiler-1.9.22.zip

# Компилируем наш файл App.kt напрямую
RUN /opt/kotlinc/bin/kotlinc App.kt -cp "java-telegram-bot-api-7.11.0.jar:okhttp-4.12.0.jar:okio-jvm-3.9.0.jar:gson-2.10.1.jar" -include-runtime -d bot.jar

# Шаг 2: Запуск готового бота на чистой Java
FROM openjdk:17-slim
EXPOSE 8080
WORKDIR /app

# Забираем скомпилированный бот и библиотеки из шага сборки
COPY --from=build /app/app/src/main/kotlin/org/example/*.jar /app/
ENTRYPOINT ["java", "-cp", "bot.jar:java-telegram-bot-api-7.11.0.jar:okhttp-4.12.0.jar:okio-jvm-3.9.0.jar:gson-2.10.1.jar", "org.example.AppKt"]
