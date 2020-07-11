# frozen_string_literal: true

module AdminActions
  def add_admin_action
    text = message.text.split(' ')
    ReceiverButtonHelper.check_db_string(text) ? true : raise('Input check failed')
  rescue Exception => e
    Db::ErrorLog.instance.log_error(level: inspect + '=>' + caller[0][/`.*'/][1..-2], message: message, exception: e.inspect)
    send_message(text: 'manage_admins_error')
    Db::User.instance.set_status(status: Config::AdminStatus::MENU, user_id: message.from.id.to_s)
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
      # returning user to queue, if moderator was reviewing the request
      admin_name = db_data.map{|admin| admin.last if admin.include?(to_delete.to_i) }.compact.first
      user_id = Db::User.instance.get_queued_user(admin_name: admin_name)[:user_id]
      Db::User.instance.set_status(user_id: user_id, status: Config::Status::IN_PROGRESS)
      # deleting board, returning to menu
      markup = MakeInlineMarkup.delete_board
      send_message(text: 'manage_admins_deleted', markup: markup)
      call_menu
    else
      send_message(text: 'manage_admins_error')
      Db::User.instance.set_status(status: Config::AdminStatus::MENU, user_id: message.from.id.to_s)
    end
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
    Db::User.instance.set_status(status: Config::AdminStatus::MENU, user_id: message.from.id.to_s)
  else
    send_message(text: 'update_document_subject_succeed')
    return_users_to_subject_step
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
        Db::User.instance.set_status(status: Config::AdminStatus::MENU, user_id: message.from.id.to_s)
        return
      end
      markup = MakeInlineMarkup.delete_board
      send_message(text: 'update_document_deleted', markup: markup)
      return_users_to_subject_step
      sleep(1)
      call_menu
    else
      markup = MakeInlineMarkup.delete_board
      send_message(text: 'update_document_subject_failed', markup: markup)
      Db::User.instance.set_status(status: Config::AdminStatus::MENU, user_id: message.from.id.to_s)
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
      Db::User.instance.set_status(status: Config::AdminStatus::MENU, user_id: message.from.id.to_s)
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
    Db::User.instance.set_status(status: Config::AdminStatus::MENU, user_id: message.from.id.to_s)
  end

  def rejection_reason 
    reason = message.text
    user_id = Db::User.instance.get_user_info(user_id: message.from.id, user_name: message.from.username)[:status].split(' ').last.to_i
    Db::UserMessage.instance.del_row(user_id: user_id)
    Db::User.instance.set_status(user_id: user_id, status: Config::Status::LOGGED)
    Db::User.instance.set_status(user_id: message.from.id, status: Config::AdminStatus::MENU)
    send_message(chat_id: user_id, text: 'inpect_deny_message_to_user', additional_text: reason)
    Invoker.new.execute(InspectNostrCommand.new(Receiver.new(options: @options)))
  end

  def return_users_to_subject_step
    Db::User.instance.return_to_subject
  end
end
