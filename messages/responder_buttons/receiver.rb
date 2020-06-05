# frozen_string_literal: true

require './messages/responder_buttons/receiver_helper.rb'

class ButtonReceiver
  # admin buttons
  def add_admin
    BotOptions.instance.edit_message(text: 'manage_admins_add')
    begin
      input = BotOptions.instance.get_single_input.text.split(' ')
      ReceiverHelper.check_add_admin_input(input) ? true : raise
    rescue StandardError
      BotOptions.instance.send_message(text: 'manage_admins_error')
    else
      UserConfigDb.instance.add_admin(input: input)
      call_menu
    end
  end

  def delete_admin
    display_string, array_for_inline, markup = ReceiverHelper.display_string
    BotOptions.instance.delete_markup
    BotOptions.instance.send_message(text: 'manage_admins_delete', markup: markup, additional_text: display_string)
    to_delete = BotOptions.instance.get_single_input.text
    if array_for_inline.flatten.include?(to_delete)
      BotOptions.instance.send_message(text: 'manage_admins_error') unless UserConfigDb.instance.delete_admin(to_delete)
      BotOptions.instance.send_message(text: 'manage_admins_deleted')
      call_menu
    else
      BotOptions.instance.send_message(text: 'manage_admins_error')
    end
    # TODO: After including inspect_request block
    # change state, if a request is inspecting by this admin
    # while deleting permissions + send notification about rights
  end

  def add_subject
    BotOptions.instance.edit_message(text: 'update_document_subject')
    message = BotOptions.instance.get_single_input
    message_text = message.caption
    message_id = message.message_id
    FileConfigDb.instance.set_subject(subject: message_text, message_id: message_id)
  rescue StandardError => e
    p e
    BotOptions.instance.send_message(text: 'update_document_subject_failed')
  else
    BotOptions.instance.send_message(text: 'update_document_subject_succeed')
    sleep(1)
    call_menu
  end

  def self.edit_subject
    subject = FileConfigDb.instance.get_subjects
    BotOptions.instance.edit_message(text: 'update_document_edit_showlist')
  end

  private

  def call_menu
    Invoker.new.execute(StartCommand.new(Receiver.new))
  end
end
