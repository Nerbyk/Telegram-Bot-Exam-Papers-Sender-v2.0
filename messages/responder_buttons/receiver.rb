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
    array_wtih_admins = UserConfigDb.instance.get_admins
    display_string = ' '
    array_for_inline = []
    array_wtih_admins.each do |hash|
      display_string += "\n\n user id = #{hash[:user_id]} | #{hash[:user_name]}"
      array_for_inline << [hash[:user_id]]
    end
    p(array_for_inline)
    markup = MakeInlineMarkup.new(*array_for_inline).get_board(one_time_keyboard: true)
    BotOptions.instance.send_message(text: 'manage_admins_delete', markup: markup, additional_text: display_string)
    to_delete = BotOptions.instance.get_single_input
    if array_for_inline.flatten.include?(to_delete)
      BotOptions.instance.send_message(text: 'manage_admins_error') unless UserConfigDb.instance.delete_admin(to_delete)
      BotOptions.instance.send_message(text: 'manage_admins_deleted')
      Invoker.new.execute(StartCommand.new(Receiver.new))
    else
      BotOptions.instance.send_message(text: 'manage_admins_error')
    end
  end
end
