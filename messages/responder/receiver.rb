# frozen_string_literal: true

require './messages/inline_markup.rb'

class Receiver
  # Admin commands
  def admin_start
    BotOptions.instance.send_message(text: 'greeting_menu')
  end

  def admin_manage_admins
    inline_buttons = MakeInlineMarkup.new(['Добавить админа', 'Add Admin'], ['Удалить админа', 'Delete Admin']).get_markup
    BotOptions.instance.send_message(text: 'manage_admins', markup: inline_buttons)
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
