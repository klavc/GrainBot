package org.example

import com.pengrad.telegrambot.TelegramBot
import com.pengrad.telegrambot.UpdatesListener
import com.pengrad.telegrambot.model.request.InlineKeyboardButton
import com.pengrad.telegrambot.model.request.InlineKeyboardMarkup
import com.pengrad.telegrambot.request.SendMessage

// Сессии игроков (бот запоминает ресурсы каждого пользователя отдельно)
val playerSessions = mutableMapOf<Long, BotGameState>()

class BotGameState {
    var year = 1
    var grain = 2800
    var population = 100
    var acres = 1000
    var warriors = 10
}

fun main() {
    val token = "8986003437:AAHk7-0DCqx0y3WRYJaYxRboilhNVyZslnM"
    val bot = TelegramBot(token)

    println("🤖 Игровой сервер 'Король Зерна' успешно запущен!")

    bot.setUpdatesListener { updates ->
        for (update in updates) {
            // 1. ЛОВИМ ТЕКСТОВЫЕ КОМАНДЫ (например, /start)
            if (update.message() != null && update.message().text() != null) {
                val chatId = update.message().chat().id()
                if (update.message().text() == "/start") {
                    playerSessions[chatId] = BotGameState()
                    sendMainScreen(bot, chatId, playerSessions[chatId]!!)
                }
            }

            // 2. ЛОВИМ НАЖАТИЯ НА ИНЛАЙН-КНОПКИ
            if (update.callbackQuery() != null) {
                val chatId = update.callbackQuery().from().id()
                val data = update.callbackQuery().data()
                val state = playerSessions[chatId] ?: BotGameState()

                when (data) {
                    "go_main" -> sendMainScreen(bot, chatId, state)
                    "go_trade" -> sendTradeScreen(bot, chatId, state)
                    "buy_100" -> {
                        if (state.grain >= 2000) {
                            state.acres += 100
                            state.grain -= 2000
                        }
                        sendTradeScreen(bot, chatId, state)
                    }
                    "sell_100" -> {
                        if (state.acres >= 100) {
                            state.acres -= 100
                            state.grain += 2000
                        }
                        sendTradeScreen(bot, chatId, state)
                    }
                }
            }
        }
        UpdatesListener.CONFIRMED_UPDATES_ALL
    }
}

fun sendMainScreen(bot: TelegramBot, chatId: Long, state: BotGameState) {
    val text =
            """
        === 🏰 КОРОЛЬ ЗЕРНА (ГОД ${state.year}) ===
        🕵️‍♂️ Советник: «Приветствую, Сир! Вот текущие ресурсы королевства:»
        
        🗺️ Земли:      ${state.acres} акров
        🌾 Зерно:      ${state.grain} бушелей
        👨‍🌾 Крестьяне:  ${state.population} человек
        ⚔️ Воины:      ${state.warriors} бойцов
    """.trimIndent()

    val inlineKeyboard =
            InlineKeyboardMarkup(
                    arrayOf(InlineKeyboardButton("🛒 Торговля землей").callbackData("go_trade"))
            )
    bot.execute(SendMessage(chatId, text).replyMarkup(inlineKeyboard))
}

fun sendTradeScreen(bot: TelegramBot, chatId: Long, state: BotGameState) {
    val text =
            """
        === 🛒 ЭКРАН 2: ТОРГОВЛЯ ЗЕМЛЕЙ ===
        Ваше Величество, цена земли сегодня — 20 бушелей за акр.
        📦 Зерно в амбарах: ${state.grain} буш.
        🗺️ Текущие земли:   ${state.acres} акров.
    """.trimIndent()

    val inlineKeyboard =
            InlineKeyboardMarkup(
                    arrayOf(
                            InlineKeyboardButton("➕ Купить 100 акров").callbackData("buy_100"),
                            InlineKeyboardButton("➖ Продать 100 акров").callbackData("sell_100")
                    ),
                    arrayOf(InlineKeyboardButton("↩️ На главную").callbackData("go_main"))
            )
    bot.execute(SendMessage(chatId, text).replyMarkup(inlineKeyboard))
}
