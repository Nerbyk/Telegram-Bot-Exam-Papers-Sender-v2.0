# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require './bot_options.rb'
require './messages/responder/responder.rb'
require './messages/responder_buttons/responder.rb'
require './config_vars/config_vars.rb'
require './db/db.rb'
require './services/req_amount_observer.rb'

Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  BotOptions.instance.bot = bot
  bot.listen do |message|
    options = { bot: bot, message: message }
  begin
     case message
     when Telegram::Bot::Types::CallbackQuery
       ButtonResponder.new(options: options).respond
     else
       MessageResponder.new(options: options).respond if message.chat.type != 'channel' # restrict access to channels
     end
  rescue StandardError => exception
    Db::ErrorLog.instance.log_error(level: 'high' + '=>' + caller[0][/`.*'/][1..-2], message: message, exception: exception.inspect)
  end
  end
end
