# frozen_string_literal: true

require 'singleton'

class BotOptions
  include Singleton
  attr_accessor :bot
  def initialize
    @bot = "bot wasn't initialized"
  end
end

module BotActions
  def send_message(chat_id: message.from.id, text:, markup: nil, additional_text: '')
    bot.api.send_message(chat_id: chat_id,
                         text: my_text.reply(text) + additional_text,
                         reply_markup: markup)
  end

  def send_message_parse_mode(chat_id: message.from.id, text:, markup: nil)
    bot.api.send_message(chat_id: chat_id,
                         text: text,
                         reply_markup: markup,
                         parse_mode: 'HTML')
  end

  def forward_message(chat_id: message.from.id, from_chat_id: message.from.id, message_id:)
    bot.api.forward_message(chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id)
  end

  def delete_markup
    bot.api.edit_message_reply_markup(chat_id: message.from.id,
                                      message_id: message.message.message_id)
  end

  def edit_message(text: nil, markup: nil, additional_text: '')
    bot.api.edit_message_text(chat_id: message.from.id,
                              message_id: message.message.message_id,
                              text: my_text.reply(text) + additional_text,
                              reply_markup: markup)
  end

  def send_photo(text: nil, markup: nil, photo: nil, additional_text: '')
    bot.api.send_photo(chat_id: message.from.id,
                       photo: photo,
                       caption: my_text.reply(text) + additional_text,
                       reply_markup: markup)
  end

  def send_photo_parse_mode(text: nil, markup: nil, photo: nil)
    bot.api.send_photo(chat_id: message.from.id,
                       photo: photo,
                       caption: text,
                       reply_markup: markup,
                       parse_mode: 'HTML')
  end
end
