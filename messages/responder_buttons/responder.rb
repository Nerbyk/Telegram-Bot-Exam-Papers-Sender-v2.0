# frozen_string_literal: true

require './messages/responder_buttons/invoker.rb'
require './messages/responder_buttons/receiver.rb'
require './messages/responder_buttons/buttons.rb'
class ButtonResponder
  def initialize
    @receiver = ButtonReceiver.new
    @invoker = ButtonInvoker.new
    GetUserRole.user_role
  end

  def respond
    case BotOptions.instance.message.data
    when  CfgConst::BotButtons::ADD_ADMIN then @invoker.execute(AddAdminButton.new(@receiver))
    when  CfgConst::BotButtons::DELETE_ADMIN then @invoker.execute(DeleteAdminButton.new(@receiver))
    when  CfgConst::BotButtons::ADD_SUBJECT then @invoker.execute(AddSubjectButton.new(@receiver))
    when  CfgConst::BotButtons::EDIT_SUBJECT then @invoker.execute(EditSubjectButton.new(@receiver))
    end
  end
end
