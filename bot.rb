# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require './bot_options.rb'
require './messages/responder/responder.rb'
require './messages/responder_buttons/responder.rb'
require './messages/get_user_role.rb'
require './config_vars/config_vars.rb'
require './db/file_config.rb'
require './db/error_log_db.rb'
Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  bot.listen do |message|
    options = { bot: bot, message: message }
    # begin
    if message.chat.type != 'channel' # restrict access to channels
      case message
      when Telegram::Bot::Types::CallbackQuery
        ButtonResponder.new.respond
      else
        MessageResponder.new(options: options) # TODO: class to check role of user via DB to separate access levels
      end
    end
    #  rescue StandardError => e
    #    p e
    #  end
  end
end
