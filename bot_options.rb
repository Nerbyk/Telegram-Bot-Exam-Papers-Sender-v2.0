# frozen_string_literal: true

require 'singleton'

module BotOptions
  def send_message(text:, markup: nil, additional_text: '')
    bot.api.send_message(chat_id: message.from.id,
                         text: my_text.reply(text) + additional_text,
                         reply_markup: markup)
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

  def get_single_input
    bot.listen do |message|
      if message
        return message
      else
        return false
      end
    end
  end
end
