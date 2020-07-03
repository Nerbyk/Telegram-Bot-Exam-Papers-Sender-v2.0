# frozen_string_literal: true

module AdminActions
  def add_admin_action
    text = message.text.split(' ')
    ReceiverButtonHelper.check_db_string(text) ? true : raise('Input check failed')
  rescue Exception => e
    Db::ErrorLog.instance.log_error(level: inspect + '=>' + caller[0][/`.*'/][1..-2], message: input, exception: e.inspect)
    send_message(text: 'manage_admins_error')
  else
    Db::User.instance.add_admin(input: text)
    call_menu
  end

  def delete_admin_action
    to_delete = message.text
    db_data = Db::User.instance.get_admins
    markup, available_buttons = ReceiverButtonHelper.markup_string(db_data)
    if available_buttons.flatten.include?(to_delete)
      unless Db::User.instance.delete_admin(to_delete)
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

  def add_subject_action
    user_message = message
    user_message_text = user_message.caption
    user_message_id = user_message.message_id
    raise 'Incorrect input' if user_message.caption.nil? || user_message.document.nil?

    Db::FileConfig.instance.set_subject(subject: user_message_text, message_id: user_message_id)
  rescue StandardError => e
    Db::ErrorLog.instance.log_error(level: inspect + '=>' + caller[0][/`.*'/][1..-2], message: user_message, exception: e.inspect)
    send_message(text: 'update_document_subject_failed')
  else
    send_message(text: 'update_document_subject_succeed')
    sleep(1)
    call_menu
  end

  def delete_subject_action
    subject = Db::FileConfig.instance.get_subjects
    markup, available_buttons = ReceiverButtonHelper.markup_string(subject)
    to_edit = message.text
    if available_buttons.flatten.include?(to_edit)
      unless Db::FileConfig.instance.delete_subject(to_edit)
        markup = MakeInlineMarkup.delete_board
        send_message(text: 'update_document_subject_failed', markup: markup)
        return
      end
      markup = MakeInlineMarkup.delete_board
      send_message(text: 'update_document_deleted', markup: markup)
      sleep(1)
      call_menu
    else
      markup = MakeInlineMarkup.delete_board
      send_message(text: 'update_document_subject_failed', markup: markup)
    end
  end

  def update_link_action
    new_link = message.text
    if Config::Links.instance.set_new_link(new_link)
      send_message(text: 'change_link_succeed')
      sleep(1)
      call_menu
    else
      send_message(text: 'change_link_fail')
    end
  end

  def set_alert_action
    amount = message.text
    if ReceiverHelper.is_number?(amount)
      Config::Alert.instance.amount = amount
      send_message(text: 'set_alert_succeed')
      sleep(1)
      call_menu
    else
      raise
      end
  rescue Exception => e
    Db::ErrorLog.instance.log_error(level: '/amount_to_alert', message: message, exception: e.class.to_s)
    send_message(text: 'set_alert_error')
  end
end
