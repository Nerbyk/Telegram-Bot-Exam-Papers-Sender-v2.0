# frozen_string_literal: true

class ButtonReceiver
  # admin buttons
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
      Invoker.new.execute(StartCommand.new(Receiver.new))
    end
  end

  def delete_admin
    display_string, array_for_inline, markup = get_list_of_admins
    BotOptions.instance.delete_markup
    BotOptions.instance.send_message(text: 'manage_admins_delete', markup: markup, additional_text: display_string)
    to_delete = BotOptions.instance.get_single_input
    if array_for_inline.flatten.include?(to_delete)
      BotOptions.instance.send_message(text: 'manage_admins_error') unless UserConfigDb.instance.delete_admin(to_delete)
      BotOptions.instance.send_message(text: 'manage_admins_deleted')
      Invoker.new.execute(StartCommand.new(Receiver.new))
    else
      BotOptions.instance.send_message(text: 'manage_admins_error')
    end
    # TODO: After including inspect_request block
    # change state, if a request is inspecting by this admin
    # while deleting permissions + send notification about rights
  end

  private

  def get_list_of_admins
    array_wtih_admins = UserConfigDb.instance.get_admins
    display_string = ' '
    array_for_inline = []
    array_wtih_admins.each do |hash|
      p hash[:user_id]
      display_string += "\n\n user id = #{hash[:user_id]} | #{hash[:user_name]}"
      array_for_inline << [hash[:user_id]]
    end
    p array_for_inline
    markup = MakeInlineMarkup.new(*array_for_inline).get_board
    [display_string, array_for_inline, markup]
  end
end
