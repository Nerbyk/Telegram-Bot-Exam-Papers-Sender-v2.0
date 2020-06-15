# frozen_string_literal: true

require './messages/responder/receiver.rb'
require './messages/responder/commands.rb'
require './messages/responder/invoker.rb'
# semi-abstract class
class UserRole
  def initialize
    @receiver = Receiver.new
    @invoker  = Invoker.new
  end

  # common comands
  def execute
    case BotOptions.instance.message.text
    when CfgConst::BotCommands::START then @invoker.execute(StartCommand.new(@receiver))
    end
  end
end

# invoker classes to command pattern
class User < UserRole
  def execute
    super
    case BotOptions.instance.message.text
    when CfgConst::BotCommands::USER_STATUS then p 'comming soon'
    end
  end
end

class Admin < UserRole
  def execute
    super
    case BotOptions.instance.message.text
    when CfgConst::BotCommands::MANAGE_ADMINS    then @invoker.execute(ManageAdminsCommand.new(@receiver))
    when CfgConst::BotCommands::UPDATE_DOCUMENTS then @invoker.execute(UpdateDocumentsCommand.new(@receiver))
    when CfgConst::BotCommands::UPDATE_LINK      then @invoker.execute(UpdateLinkCommand.new(@receiver))
    when CfgConst::BotCommands::SET_ALERT        then @invoker.execute(SetAlertAmountCommand.new(@receiver))
    end
  end
end

class Developer < UserRole
  def execute
    super
  end
end

class Moderator < UserRole
  def execute
    super
  end
end

class GetUserCommand < Struct.new(:role)
  def initialize(role:)
    @role = role
  end

  def call
    @role = role
    find_role_commands.new.execute
  end

  def find_role_commands
    Kernel.const_get(role.capitalize)
  end
  attr_reader :role
end
