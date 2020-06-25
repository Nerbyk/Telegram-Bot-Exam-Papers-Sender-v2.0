# frozen_string_literal: true

module AdminActions
  def add_admin_action
    text = message.text.split(' ')
    ReceiverButtonHelper.check_db_string(text) ? true : raise('Input check failed')
  rescue Exception => e
    Db::ErrorLog.instance.log_error(level: inspect + '=>' + caller[0][/`.*'/][1..-2], message: input, exception: e.inspect)
    send_message(text: 'manage_admins_error')
  else
    Db::UserConfig.instance.add_admin(input: text)
    call_menu
  end

  def delete_admin_action
    to_delete = message.text
    db_data   = Db::UserConfig.instance.get_admins
    markup, available_buttons = ReceiverButtonHelper.markup_string(db_data)
    if available_buttons.flatten.include?(to_delete)
      unless Db::UserConfig.instance.delete_admin(to_delete)
        send_message(text: 'manage_admins_error')
        return
      end
      markup = MakeInlineMarkup.delete_board
      send_message(text: 'manage_admins_deleted', markup: markup)
      call_menu
    else
      send_message(text: 'manage_admins_error')
    end
    # TODO: After including inspect_request block
    # change state, if a request is inspecting by this admin
    # while deleting permissions + send notification about rights
  end
end
