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
        if Config::Access.isntance.user
          ButtonResponder.new(options: options).respond
        elsif !Config::Access.isntance.user && (message.from.id != ENV['DEV_ID'] || message.from.id != ENV['ADMIN_ID'] )  
          bot.api.send_message(chat_id: message.from.id, text: 'in maintenance')
        end 
      else
        if Config::Access.isntance.user
          MessageResponder.new(options: options).respond if message.chat.type != 'channel' # restrict access to channels
        elsif !Config::Access.isntance.user && (message.from.id != ENV['DEV_ID'] || message.from.id != ENV['ADMIN_ID'] ) 
          bot.api.send_message(chat_id: message.from.id, text: 'in maintenance')
        end
      end
    rescue StandardError => exception
      Db::ErrorLog.instance.log_error(level: 'high' + '=>' + caller[0][/`.*'/][1..-2], message: message, exception: exception.inspect)
    end
  end
end
