# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require 'bot_options.rb'
require './messages/responder/responder.rb'
require './messages/responder_buttons/responder.rb'

Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  bot_options = BotOptions.instance
  bot_options.bot = bot # to get access to bot from everywhere without passing bot and message as argument any time
  bot.listen do |message|
    bot_options.message = message
    begin
      case message
      when Telegram::Bot::Types::CallbackQuery
        ButtonResponder.new
      else
        MessageResponder.new
      end
    rescue StandardError => e
      p e
    end
  end
end
