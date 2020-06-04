# frozen_string_literal: true

require './messages/inline_markup.rb'

class Receiver
  # Admin commands
  def admin_start
    BotOptions.instance.send_message(text: 'greeting_menu')
  end

  def admin_manage_admins
    choose_option_msg(['Добавить админа', CfgConst::BotButtons::ADD_ADMIN], ['Удалить админа', CfgConst::BotButtons::DELETE_ADMIN])
  end

  def admin_update_documents
    choose_option_msg(['Добавить новый предмет', CfgConst::BotButtons::ADD_SUBJECT], ['Редактировать Существующий', CfgConst::BotButtons::EDIT_SUBJECT])
  end

  private

  def choose_option_msg(*buttons)
    each_button = []
    (0..buttons.length - 1).each do |i|
      each_button << buttons[i]
    end
    inline_buttons = MakeInlineMarkup.new(*each_button).get_markup
    BotOptions.instance.send_message(text: 'choose_option', markup: inline_buttons)
  end

  # User commands
  def user_start
    p 'started by user'
  end

  # Developer commands
  def developer_start
    p 'started by developer'
  end

  # Moderator commands
  def moderator_start
    p 'started by moderator'
  end
end
