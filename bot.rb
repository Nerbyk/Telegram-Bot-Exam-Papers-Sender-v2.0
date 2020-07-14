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
require './messages/redirect_responder.rb'

Dotenv.load('./.env')

Telegram::Bot::Client.run(ENV['TOKEN']) do |bot|
  BotOptions.instance.bot = bot
  Notifier.about_restart
  bot.listen do |message|
    ToRespond.new(bot: bot, message: message)
  end
end
