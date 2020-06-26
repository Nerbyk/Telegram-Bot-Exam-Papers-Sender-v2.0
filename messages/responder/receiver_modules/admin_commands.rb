# frozen_string_literal: true

module AdminCommands
  def admin_start
    send_message(text: 'greeting_menu')
    Db::UserConfig.instance.set_status(status: CfgConst::AdminStatus::MENU, user_id: message.from.id.to_s)
  end

  def admin_manage_admins
    inline_buttons = ReceiverHelper.choose_option_msg(['Добавить админа', CfgConst::BotButtons::ADD_ADMIN], ['Удалить админа', CfgConst::BotButtons::DELETE_ADMIN])
    send_message(text: 'choose_option', markup: inline_buttons)
  end

  def admin_update_documents
    inline_buttons = ReceiverHelper.choose_option_msg(['Добавить новый предмет', CfgConst::BotButtons::ADD_SUBJECT], ['Редактировать Существующий', CfgConst::BotButtons::EDIT_SUBJECT])
    send_message(text: 'choose_option', markup: inline_buttons)
  end

  def admin_update_link
    send_message(text: 'change_link', additional_text: CfgConst::Links.instance.return_current_links)
    Db::UserConfig.instance.set_status(status: CfgConst::AdminStatus::UPDATE_LINK, user_id: message.from.id.to_s)
  end

  def admin_set_alert_amount
    send_message(text: 'set_alert', additional_text: CfgConst::Alert.instance.amount.to_s)
    Db::UserConfig.instance.set_status(status: CfgConst::AdminStatus::SET_ALERT, user_id: message.from.id.to_s)
  end
end
