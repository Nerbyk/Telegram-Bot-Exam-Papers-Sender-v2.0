# frozen_string_literal: true

require './messages/responder_buttons/receiver_helper.rb'
require './actions/form_filling.rb'
class ButtonReceiver
  # admin buttons
  def add_admin
    BotOptions.instance.edit_message(text: 'manage_admins_add')
    begin
      input = BotOptions.instance.get_single_input.text.split(' ')
      ReceiverHelper.check_db_string(input) ? true : raise
    rescue StandardError
      BotOptions.instance.send_message(text: 'manage_admins_error')
    else
      UserConfigDb.instance.add_admin(input: input)
      call_menu
    end
  end

  def delete_admin
    db_data = UserConfigDb.instance.get_admins
    display_string = ReceiverHelper.display_string(db_data)
    markup, available_buttons = ReceiverHelper.markup_string(db_data)

    BotOptions.instance.send_message(text: 'manage_admins_delete', markup: markup, additional_text: display_string)
    to_delete = BotOptions.instance.get_single_input.text
    if available_buttons.flatten.include?(to_delete)
      unless UserConfigDb.instance.delete_admin(to_delete)
        BotOptions.instance.send_message(text: 'manage_admins_error')
        return
      end
      markup = MakeInlineMarkup.delete_board
      BotOptions.instance.send_message(text: 'manage_admins_deleted', markup: markup)
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

  def edit_subject
    subject = FileConfigDb.instance.get_subjects
    markup, available_buttons = ReceiverHelper.markup_string(subject)
    subject.map(&:reverse!)
    display_string = ReceiverHelper.display_string(subject)
    BotOptions.instance.send_message(text: 'update_document_edit_showlist', additional_text: display_string, markup: markup)
    to_edit = BotOptions.instance.get_single_input.text
    if available_buttons.flatten.include?(to_edit)
      unless FileConfigDb.instance.delete_subject(to_edit)
        BotOptions.instance.send_message(text: 'update_document_subject_failed')
        return
      end
      markup = MakeInlineMarkup.delete_board
      BotOptions.instance.send_message(text: 'update_document_deleted', markup: markup)
      sleep(1)
      call_menu
    else
      BotOptions.instance.send_message(text: 'update_document_subject_failed')
    end
  end

  # user buttons
  def start_nostrification
    Form.new.start
  end

  def start_advertisement
    p 'in progress'
  end

  private

  def call_menu
    Invoker.new.execute(StartCommand.new(Receiver.new))
  end
end
