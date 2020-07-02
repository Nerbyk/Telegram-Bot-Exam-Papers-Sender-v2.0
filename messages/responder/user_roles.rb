# frozen_string_literal: true

require './messages/responder/receiver.rb'
require './messages/responder/commands.rb'
require './messages/responder/invoker.rb'
# semi-abstract class
class UserRole
  def initialize(options:)
    @options = options
    @receiver = Receiver.new(options: options)
    @invoker  = Invoker.new
  end

  # common comands
  def execute
    @verification = Db::User.instance.get_user_info(user_id: @options[:message].from.id.to_s,
                                                    user_name: @options[:message].from.username)[:status]
    case @options[:message].text
    when CfgConst::BotCommands::START then @invoker.execute(StartCommand.new(@receiver, @options))
    end
  end
end

# invoker classes to command pattern
class User < UserRole
  def execute
    super
    if @verification != CfgConst::Status::LOGGED
      @invoker.execute(FormFillingAction.new(@receiver)) if @options[:message]
    elsif @verification == CfgConst::Status::LOGGED && @options[:message].text != CfgConst::BotCommands::START
      @invoker.execute(UnexpectedCommand.new(@receiver, @options))
    end
  end
end

class Admin < UserRole
  def execute
    super
    if @options[:message]

      if @options[:message].text == CfgConst::BotCommands::MANAGE_ADMINS
        @invoker.execute(ManageAdminsCommand.new(@receiver))
      end
      if @options[:message].text == CfgConst::BotCommands::UPDATE_DOCUMENTS
        @invoker.execute(UpdateDocumentsCommand.new(@receiver))
      end
      if @options[:message].text == CfgConst::BotCommands::UPDATE_LINK
        @invoker.execute(UpdateLinkCommand.new(@receiver))
      end
      if @options[:message].text == CfgConst::BotCommands::SET_ALERT
        @invoker.execute(SetAlertAmountCommand.new(@receiver))
      end
      case @verification
      when CfgConst::AdminStatus::ADD_ADMIN      then @invoker.execute(AddAdminAction.new(@receiver))
      when CfgConst::AdminStatus::DELETE_ADMIN   then @invoker.execute(DeleteAdminAction.new(@receiver))
      when CfgConst::AdminStatus::ADD_SUBJECT    then @invoker.execute(AddSubjectAction.new(@receiver))
      when CfgConst::AdminStatus::DELETE_SUBJECT then @invoker.execute(DeleteSubjectAction.new(@receiver))
      when CfgConst::AdminStatus::UPDATE_LINK    then @invoker.execute(UpdatLinkAction.new(@receiver))
      when CfgConst::AdminStatus::SET_ALERT      then @invoker.execute(SetAlertAction.new(@receiver))
      end
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
  attr_reader :options, :role
  def initialize(options:)
    @option = options
    @role   = options[:role]
  end

  def call(options)
    find_role_commands.new(options: options).execute
  end

  def find_role_commands
    Kernel.const_get(role.capitalize)
  end
end
