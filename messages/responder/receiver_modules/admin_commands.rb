# frozen_string_literal: true

module AdminCommands
  def admin_manage_admins
    inline_buttons = ReceiverHelper.choose_option_msg(['Добавить админа', Config::BotButtons::ADD_ADMIN], ['Удалить админа', Config::BotButtons::DELETE_ADMIN])
    send_message(text: 'choose_option', markup: inline_buttons)
  end

  def admin_update_documents
    inline_buttons = ReceiverHelper.choose_option_msg(['Добавить новый предмет', Config::BotButtons::ADD_SUBJECT], ['Редактировать Существующий', Config::BotButtons::EDIT_SUBJECT])
    send_message(text: 'choose_option', markup: inline_buttons)
  end

  def admin_update_link
    send_message(text: 'change_link', additional_text: Config::Links.instance.get_links)
    Db::User.instance.set_status(status: Config::AdminStatus::UPDATE_LINK, user_id: message.from.id.to_s)
  end

  def admin_set_alert_amount
    send_message(text: 'set_alert', additional_text: Config::Alert.instance.amount.to_s)
    Db::User.instance.set_status(status: Config::AdminStatus::SET_ALERT, user_id: message.from.id.to_s)
  end

  def settings
    send_message(text: 'settings')
  end
end
