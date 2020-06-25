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
    new_link = get_single_input.text
    if CfgConst::Links.instance.set_new_link(new_link)
        send_message(text: 'change_link_succeed')
        sleep(1)
        call_menu
    else
        send_message(text: 'change_link_fail')
    end
    end

    def admin_set_alert_amount
    send_message(text: 'set_alert', additional_text: CfgConst::Alert.instance.amount.to_s)
    amount = get_single_input.text
    if ReceiverHelper.is_number?(amount)
        CfgConst::Alert.instance.amount = amount
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