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
require './messages/get_message.rb'
include BotActions
Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  BotOptions.instance.bot = bot
  Notifier.about_restart
  bot.listen do |message|
  
  my_text = GetMessageText.new(client: 'config')
    if Config::Access.instance.user
      options = { bot: bot, message: message }
      begin
        case message
        when Telegram::Bot::Types::CallbackQuery
          ButtonResponder.new(options: options).respond
        else
          MessageResponder.new(options: options).respond if message.chat.type != 'channel' # restrict access to channels
        end
      rescue StandardError => exception
        send_message(text: 'exception_message')
        Db::ErrorLog.instance.log_error(level: 'high' + '=>' + caller[0][/`.*'/][1..-2], message: message, exception: exception.inspect)
      end
    else  
      if message.from.id == ENV['ADMIN_ID'] || message.from.id == ENV['DEV_ID']
        options = { bot: bot, message: message }
        begin
          case message
          when Telegram::Bot::Types::CallbackQuery
            ButtonResponder.new(options: options).respond
          else
            MessageResponder.new(options: options).respond if message.chat.type != 'channel' # restrict access to channels
          end
        rescue StandardError => exception
          send_message(text: 'exception_message')
          Db::ErrorLog.instance.log_error(level: 'high' + '=>' + caller[0][/`.*'/][1..-2], message: message, exception: exception.inspect)
        end
      else  
        send_message(text: 'maintenance')
      end
    end
    
  end
end
