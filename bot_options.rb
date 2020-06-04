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

  def send_message(text:, markup: nil, additional_text: '')
    bot.api.send_message(chat_id: message.from.id,
                         text: my_text.reply(text) + additional_text,
                         reply_markup: markup)
  end

  def delete_markup
    bot.api.edit_message_reply_markup(chat_id: message.from.id,
                                      message_id: message.message.message_id)
  end

  def edit_message(text:, markup: nil, additional_text: '')
    bot.api.edit_message_text(chat_id: message.from.id,
                              message_id: message.message.message_id,
                              text: my_text.reply(text) + additional_text,
                              reply_markup: markup)
  rescue StandardError
    send_message(text: 'admin_exception_error')
  end

  def get_single_input
    bot.listen do |message|
      if message.text
        return message.text
      else
        return false
      end
    end
  end
end
