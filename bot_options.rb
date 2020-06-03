# frozen_string_literal: true

require 'singleton'

class BotOptions
  attr_accessor :bot, :message, :role, :my_text
  include Singleton
  def initialize
    @bot = bot
    @message = message
    @role = role
    @my_text = my_text
  end

  def send_message(text:, markup: nil)
    bot.api.send_message(chat_id: message.from.id, text: my_text.reply(text), reply_markup: markup)
  end

  def delete_markup
    bot.api.reply_keyboard_remove(remove_keyboard: true)
  end
end
