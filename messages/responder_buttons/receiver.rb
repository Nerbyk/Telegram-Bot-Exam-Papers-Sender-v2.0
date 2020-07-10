# frozen_string_literal: true

require './messages/responder_buttons/receiver_helper.rb'
require './actions/form_filling.rb'
class ButtonReceiver
  attr_reader :bot, :message, :my_text
  include BotActions
  def initialize(options:)
    @options = options
    @bot     = options[:bot]
    @message = options[:message]
    @my_text = options[:my_text]
  end

  # admin buttons
  def add_admin
    edit_message(text: 'manage_admins_add')
    Db::User.instance.set_status(status: Config::AdminStatus::ADD_ADMIN, user_id: message.from.id.to_s)
  end

  def delete_admin
    db_data = Db::User.instance.get_admins
    display_string = ReceiverButtonHelper.display_string(db_data)
    markup = ReceiverButtonHelper.markup_string(db_data).first
    send_message(text: 'manage_admins_delete', markup: markup, additional_text: display_string)
    Db::User.instance.set_status(status: Config::AdminStatus::DELETE_ADMIN, user_id: message.from.id.to_s)
  end

  def add_subject
    edit_message(text: 'update_document_subject')
    Db::User.instance.set_status(status: Config::AdminStatus::ADD_SUBJECT, user_id: message.from.id.to_s)
  end

  def edit_subject
    subject = Db::FileConfig.instance.get_subjects
    markup = ReceiverButtonHelper.markup_string(subject).first
    subject.map(&:reverse!)
    display_string = ReceiverButtonHelper.display_string(subject)
    send_message(text: 'update_document_edit_showlist', additional_text: display_string, markup: markup)
    Db::User.instance.set_status(status: Config::AdminStatus::DELETE_SUBJECT, user_id: message.from.id.to_s)
  end

  def accept_request
    delete_markup
    admin_name = Db::User.instance.get_admin_name(user_id: message.from.id)
    inspectable_user = Db::User.instance.get_queued_user(admin_name: admin_name)
    subjects = Db::UserMessage.instance.get_user_data(user_id: inspectable_user[:user_id])[:subjects].split(';')
    subjects.each do |subject|
      message_id = Db::FileConfig.instance.get_message_id(subject: subject).to_i
      forward_message(chat_id: inspectable_user[:user_id].to_i,
                      from_chat_id: ENV['ADMIN_ID'],
                      message_id: message_id)
    end
    send_message(chat_id: inspectable_user[:user_id].to_i, text: 'inpect_accept_message_to_user')
    Db::User.instance.set_status(status: Config::Status::ACCEPTED,
                                 user_id: inspectable_user[:user_id])
    Invoker.new.execute(InspectNostrCommand.new(Receiver.new(options: @options)))
  end

  def deny_request
    p 'deny pushed'
  end

  def ban_request
    p 'ban pushed'
  end

  def return_to_menu
    call_menu
  end

  # user buttons
  def start_nostrification
    Form.new(options: @options).start
  end

  def send_user_request
    delete_markup
    AmountOfRequests.instance.log
    Db::User.instance.set_status(status: Config::Status::IN_PROGRESS, user_id: message.from.id.to_s)
    send_message(text: 'request_sent')
    # Form.new(options: @options).start
  end

  def reset_user_request
    delete_markup
    Db::UserMessage.instance.reset_row(user_id: message.from.id.to_s)
    Db::User.instance.set_status(status: Config::Status::LOGGED, user_id: message.from.id.to_s)
    Form.new(options: @options).start
  end

  def start_advertisement
    p 'comming soon'
  end

  private

  def delete_markup
    bot.api.edit_message_reply_markup(chat_id: message.from.id, message_id: message.message.message_id)
  end

  def call_menu
    Invoker.new.execute(StartCommand.new(Receiver.new(options: @options), @options))
  end
end
