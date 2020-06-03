# frozen_string_literal: true

class ButtonReceiver
  def add_admin
    BotOptions.instance.edit_message(text: 'manage_admins_add')
    begin
      input = BotOptions.instance.get_single_input.split(' ')
      raise if input.length != 2
      raise unless input.first.to_i.is_a? Integer
      raise unless input.last.is_a? String
    rescue StandardError
      BotOptions.instance.send_message(text: 'manage_admins_error')
    else
      UserConfigDb.instance.add_admin(input: input)
    end
  end

  def delete_admin
    p 'delete pushed'
  end
end
