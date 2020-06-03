# frozen_string_literal: true

class Receiver
  # Admin commands
  def admin_start
    BotOptions.instance.send_message(text: 'greeting_menu')
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
