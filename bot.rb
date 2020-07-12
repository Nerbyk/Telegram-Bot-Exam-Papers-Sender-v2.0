# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require './bot_options.rb'
require './messages/responder/responder.rb'
require './messages/responder_buttons/responder.rb'
require './config_vars/config_vars.rb'
require './db/db.rb'
require './services/req_amount_observer.rb'
require './services/restart_notifier.rb'

Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  BotOptions.instance.bot = bot
  Notifier.about_restart
  bot.listen do |message|
    options = { bot: bot, message: message }
    begin
      case message
      when Telegram::Bot::Types::CallbackQuery
        if Config::Access.instance.user || (message.from.id == ENV['DEV_ID'].to_i || message.from.id == ENV['ADMIN_ID'].to_i)
          ButtonResponder.new(options: options).respond
        elsif !Config::Access.instance.user
          bot.api.send_message(chat_id: message.from.id, text: 'В данный момент ведутся технические работы, бот будет доступен в ближайший час.')
        end
      else
        if Config::Access.instance.user || (message.from.id == ENV['DEV_ID'].to_i || message.from.id == ENV['ADMIN_ID'].to_i)
          MessageResponder.new(options: options).respond if message.chat.type != 'channel' # restrict access to channels
        elsif !Config::Access.instance.user
          bot.api.send_message(chat_id: message.from.id, text: 'В данный момент ведутся технические работы, бот будет доступен в ближайший час.')
        end
      end
    rescue StandardError => e
      bot.api.send_message(chat_id: message.from.id, text: "Пожалуйста введите данные требуемого формата.\n\nПри возникновении трудностей свяжитесь с <a href=\"tg://user?id=143845427\">Разрабочиком</a>", parse_mode: 'HTML')
      Db::ErrorLog.instance.log_error(level: 'high' + '=>' + caller[0][/`.*'/][1..-2], message: message, exception: e.inspect)
    end
  end
end
