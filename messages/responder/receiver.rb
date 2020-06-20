# frozen_string_literal: true

require './messages/inline_markup.rb'
require './messages/responder/receiver_helper.rb'
class Receiver
  attr_reader :bot, :message, :my_text
  include BotOptions
  def initialize(options:)
    @options = options
    @bot     = options[:bot]
    @message = options[:message]
    @my_text = options[:my_text]
  end

  # Admin commands
  def admin_start
    send_message(text: 'greeting_menu')
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
    ErrorLogDb.instance.log_error(level: '/amount_to_alert', message: message, exception: e.class.to_s)
    send_message(text: 'set_alert_error')
  end

  # user panel
  def user_start
    markup = MakeInlineMarkup.new(['Билеты к Нострификации', 'Start Nostrification'], ['Объявление Барахолка', 'Start Ad']).get_markup
    send_message(text: 'greeting_first_time_user', markup: markup)
  end

  private

  def call_menu
    Invoker.new.execute(StartCommand.new(Receiver.new(options: @options), @options))
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
