# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require './bot_options.rb'
require './messages/responder/responder.rb'
require './messages/responder_buttons/responder.rb'
require './config_vars/config_vars.rb'
require './db/db.rb'

Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  bot.listen do |message|
    options = { bot: bot, message: message }
    # begin
    case message
    when Telegram::Bot::Types::CallbackQuery
      ButtonResponder.new(options: options).respond
    else
      MessageResponder.new(options: options).respond if message.chat.type != 'channel' # restrict access to channels
    end
    #  rescue StandardError => e
    #    p e
    #  end
  end
end
