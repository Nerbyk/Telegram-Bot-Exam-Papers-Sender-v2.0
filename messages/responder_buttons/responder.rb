# frozen_string_literal: true

require './messages/responder_buttons/invoker.rb'
require './messages/responder_buttons/receiver.rb'
require './messages/responder_buttons/buttons.rb'

require './messages/get_message.rb'
require './messages/responder/user_roles.rb'
require './db/user_config.rb'

class ButtonResponder < MessageResponder # to inherit initialization, especially bot options
  def initialize(options:)
    super
    @receiver = ButtonReceiver.new(options: options)
    @invoker = ButtonInvoker.new
  end

  def respond
    case  @message.data
    when  CfgConst::BotButtons::ADD_ADMIN then @invoker.execute(AddAdminButton.new(@receiver))
    when  CfgConst::BotButtons::DELETE_ADMIN then @invoker.execute(DeleteAdminButton.new(@receiver))
    when  CfgConst::BotButtons::ADD_SUBJECT then @invoker.execute(AddSubjectButton.new(@receiver))
    when  CfgConst::BotButtons::EDIT_SUBJECT then @invoker.execute(EditSubjectButton.new(@receiver))
    when  CfgConst::BotButtons::START_NOSTR then @invoker.execute(StartNostrButton.new(@receiver))
    when  CfgConst::BotButtons::START_AD then @invoker.execute(StartAdButton.new(@receiver))
    end
  end
end
