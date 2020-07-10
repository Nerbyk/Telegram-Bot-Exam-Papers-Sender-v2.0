# frozen_string_literal: true

require './messages/responder_buttons/invoker.rb'
require './messages/responder_buttons/receiver.rb'
require './messages/responder_buttons/buttons.rb'
require './messages/get_message.rb'
require './messages/responder/user_roles.rb'

class ButtonResponder < MessageResponder # to inherit initialization, especially bot options
  def initialize(options:)
    super
    @receiver = ButtonReceiver.new(options: options)
    @invoker = ButtonInvoker.new
  end

  def respond
    case  @message.data
    when  Config::BotButtons::ADD_ADMIN then @invoker.execute(AddAdminButton.new(@receiver))
    when  Config::BotButtons::DELETE_ADMIN then @invoker.execute(DeleteAdminButton.new(@receiver))
    when  Config::BotButtons::ADD_SUBJECT then @invoker.execute(AddSubjectButton.new(@receiver))
    when  Config::BotButtons::EDIT_SUBJECT then @invoker.execute(EditSubjectButton.new(@receiver))
    when  Config::BotButtons::START_NOSTR then @invoker.execute(StartNostrButton.new(@receiver))
    when  Config::BotButtons::START_AD then @invoker.execute(StartAdButton.new(@receiver))
    when  Config::BotButtons::SEND_REQ then @invoker.execute(SendRequestButton.new(@receiver))
    when  Config::BotButtons::RESET_REQ then @invoker.execute(ResetRequestButton.new(@receiver))
    when Config::BotButtons::ACCEPT_REQ then @invoker.execute(AcceptRequesButton.new(@receiver))
    when Config::BotButtons::DENY_REQ then @invoker.execute(DenyRequesButton.new(@receiver))
    when Config::BotButtons::BAN_REQ then @invoker.execute(BanRequesButton.new(@receiver))
    when Config::BotButtons::MENU then @invoker.execute(ReturnToMenuButton.new(@receiver))
    end
  end
end
