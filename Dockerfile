# ИСПОЛЬЗУЕМ СТАБИЛЬНЫЙ ОБРАЗ С KOTLIN И JAVA 17
FROM zenika/kotlin:1.9.22-jdk17

# Создаем рабочую папку
WORKDIR /app

# Копируем всё содержимое репозитория в контейнер
COPY . .

# Переходим в папку, где физически лежит ваш файл App.kt
WORKDIR /app/app/src/main/kotlin/org/example

# Скачиваем саму библиотеку Telegram (jar-файл) прямо в папку к коду
RUN wget https://maven.org && \
    wget https://maven.org && \
    wget https://maven.org && \
    wget https://maven.org

# Компилируем наш файл App.kt вместе со всеми скачанными библиотеками
RUN kotlinc App.kt -cp "java-telegram-bot-api-7.11.0.jar:okhttp-4.12.0.jar:okio-jvm-3.9.0.jar:gson-2.10.1.jar" -include-runtime -d bot.jar

# Открываем порт
EXPOSE 8080

# Запускаем скомпилированного бота
ENTRYPOINT ["java", "-cp", "bot.jar:java-telegram-bot-api-7.11.0.jar:okhttp-4.12.0.jar:okio-jvm-3.9.0.jar:gson-2.10.1.jar", "org.example.AppKt"]
