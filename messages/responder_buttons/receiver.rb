# frozen_string_literal: true

require './messages/responder_buttons/receiver_helper.rb'
require './actions/form_filling.rb'
class ButtonReceiver
  attr_reader :bot, :message, :my_text
  include BotOptions
  def initialize(options:)
    @options = options
    @bot     = options[:bot]
    @message = options[:message]
    @my_text = options[:my_text]
  end

  # admin buttons
  def add_admin
    edit_message(text: 'manage_admins_add')
    Db::UserConfig.instance.set_status(status: CfgConst::AdminStatus::ADD_ADMIN, user_id: message.from.id.to_s)
  end

  def delete_admin
    db_data = Db::UserConfig.instance.get_admins
    display_string = ReceiverButtonHelper.display_string(db_data)
    markup, available_buttons = ReceiverButtonHelper.markup_string(db_data)
    send_message(text: 'manage_admins_delete', markup: markup, additional_text: display_string)
    Db::UserConfig.instance.set_status(status: CfgConst::AdminStatus::DELETE_ADMIN, user_id: message.from.id.to_s)
  end

  def add_subject
    edit_message(text: 'update_document_subject')
    user_message = get_single_input
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

  def edit_subject
    subject = Db::FileConfig.instance.get_subjects
    markup, available_buttons = ReceiverButtonHelper.markup_string(subject)
    subject.map(&:reverse!)
    display_string = ReceiverButtonHelper.display_string(subject)
    send_message(text: 'update_document_edit_showlist', additional_text: display_string, markup: markup)
    to_edit = get_single_input.text
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

  # user buttons
  def start_nostrification
    Form.new(options: @options).start
  end

  def start_advertisement
    p 'in progress'
  end

  private

  def call_menu
    Invoker.new.execute(StartCommand.new(Receiver.new(options: @options), @options))
  end
end
