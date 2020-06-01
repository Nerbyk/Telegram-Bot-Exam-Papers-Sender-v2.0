# frozen_string_literal: true

require './messages/get_message.rb'

class BotOptions
  attr_accessor :bot, :message, :client
  include Singleton
  def initialize(client: 'config')
    @bot = bot
    @client = client
    @message = message
  end

  def send_message(text:, markup: nil)
    bot.api.send_message(chat_id: message.from.id, text: GetMessageText.new(client: client).reply(text), reply_markup: markup)
  end

  def delete_markup
    bot.api.reply_keyboard_remove(remove_keyboard: true)
  end
end
