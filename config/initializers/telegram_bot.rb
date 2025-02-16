if Rails.env.production? || Rails.env.development?
  Thread.new do
    puts 'Запуск телеграм бота'
    bot = TelegramBot.new
    bot.start
  rescue StandardError => e
    Rails.logger.error "Ошибка в телеграм боте: #{e.message}"
    sleep 5
    retry
  end
end
