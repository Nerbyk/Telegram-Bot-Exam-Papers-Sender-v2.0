# frozen_string_literal: true

require './messages/inline_markup.rb'
require './messages/responder/receiver_helper.rb'
class Receiver
  # Admin commands
  def admin_start
    BotOptions.instance.send_message(text: 'greeting_menu')
  end

  def admin_manage_admins
    ReceiverHelper.choose_option_msg(['Добавить админа', CfgConst::BotButtons::ADD_ADMIN], ['Удалить админа', CfgConst::BotButtons::DELETE_ADMIN])
  end

  def admin_update_documents
    ReceiverHelper.choose_option_msg(['Добавить новый предмет', CfgConst::BotButtons::ADD_SUBJECT], ['Редактировать Существующий', CfgConst::BotButtons::EDIT_SUBJECT])
  end

  def admin_update_link
    BotOptions.instance.send_message(text: 'change_link', additional_text: CfgConst::Links.instance.return_current_links)
    new_link = BotOptions.instance.get_single_input.text
    if CfgConst::Links.instance.set_new_link(new_link)
      BotOptions.instance.send_message(text: 'change_link_succeed')
      sleep(1)
      call_menu
    else
      BotOptions.instance.send_message(text: 'change_link_fail')
    end
  end

  def admin_set_alert_amount
    BotOptions.instance.send_message(text: 'set_alert', additional_text: CfgConst::Alert.instance.amount.to_s)
    amount = BotOptions.instance.get_single_input.text
    if ReceiverHelper.is_number?(amount)
      CfgConst::Alert.instance.amount = amount
      BotOptions.instance.send_message(text: 'set_alert_succeed')
      sleep(1)
      call_menu
    else
      raise
    end
  rescue Exception => e
    ErrorLogDb.instance.log_error(level: '/amount_to_alert', message: BotOptions.instance.message, exception: e.class.to_s)
    BotOptions.instance.send_message(text: 'set_alert_error')
  end

  # user panel
  def user_start
    markup = MakeInlineMarkup.new(['Билеты к Нострификации', 'Start Nostrification'], ['Объявление Барахолка', 'Start Ad']).get_markup
    BotOptions.instance.send_message(text: 'greeting_first_time_user', markup: markup)
  end

  def name_step; end

  private

  def choose_option_msg(*buttons)
    each_button = []
    (0..buttons.length - 1).each do |i|
      each_button << buttons[i]
    end
    inline_buttons = MakeInlineMarkup.new(*each_button).get_markup
    BotOptions.instance.send_message(text: 'choose_option', markup: inline_buttons)
  end

  def call_menu
    Invoker.new.execute(StartCommand.new(Receiver.new))
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
