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
    @bot      = options[:bot]
    @message  = options[:message]
  end

  # common comands
  def execute
    @verification = Db::User.instance.get_user_info(user_id: @options[:message].from.id.to_s,
                                                    user_name: @options[:message].from.username)[:status]
    return if @verification == Config::Status::BANNED

    case @options[:message].text
    when Config::BotCommands::START then @invoker.execute(StartCommand.new(@receiver, @options))
    end
  end
end

# invoker classes to command pattern
class User < UserRole
  include BotActions
  attr_reader :bot, :message
  def execute
    super
    if @verification != Config::Status::LOGGED
      @invoker.execute(FormFillingAction.new(@receiver)) if @options[:message]
    elsif @verification == Config::Status::LOGGED && @options[:message].text != Config::BotCommands::START
      @invoker.execute(UnexpectedCommand.new(@receiver, @options))
    end
  end
end

class Admin < UserRole
  def execute
    super
    if @options[:message]

      if @options[:message].text == Config::BotCommands::MANAGE_ADMINS
        @invoker.execute(ManageAdminsCommand.new(@receiver))
      elsif @options[:message].text == Config::BotCommands::UPDATE_DOCUMENTS
        @invoker.execute(UpdateDocumentsCommand.new(@receiver))
        @invoker.execute(UpdateLinkCommand.new(@receiver)) if @options[:message].text == Config::BotCommands::UPDATE_LINK
      elsif @options[:message].text == Config::BotCommands::SET_ALERT
        @invoker.execute(SetAlertAmountCommand.new(@receiver))
      elsif @options[:message].text == Config::BotCommands::INSPECT_NOST
        @invoker.execute(InspectNostrCommand.new(@receiver))
      elsif @options[:message].text == Config::BotCommands::ADMIN_SETTING
        @invoker.execute(SettingsCommand.new(@receiver))
      elsif @options[:message].text == Config::BotCommands::AMOUNT
        @invoker.execute(AmountCommand.new(@receiver))
      end

      case @verification
      when Config::AdminStatus::ADD_ADMIN      then @invoker.execute(AddAdminAction.new(@receiver))
      when Config::AdminStatus::DELETE_ADMIN   then @invoker.execute(DeleteAdminAction.new(@receiver))
      when Config::AdminStatus::ADD_SUBJECT    then @invoker.execute(AddSubjectAction.new(@receiver))
      when Config::AdminStatus::DELETE_SUBJECT then @invoker.execute(DeleteSubjectAction.new(@receiver))
      when Config::AdminStatus::UPDATE_LINK    then @invoker.execute(UpdatLinkAction.new(@receiver))
      when Config::AdminStatus::SET_ALERT      then @invoker.execute(SetAlertAction.new(@receiver))
      end
      if @verification.split(' ').first == Config::AdminStatus::DENY_REASON
        @invoker.execute(EnterRejectionReasonAction.new(@receiver))
      end
    end
  end
end

class Developer < UserRole
  def execute
    super
    if @message.text.include?(Config::DevCommands::RESET)
      @invoker.execute(ResetDeveloeprCommand.new(@receiver))
    elsif @message.text.include?(Config::DevCommands::FREEZE)
      @invoker.execute(FreezeDeveloperCommand.new(@receiver))
    elsif @message.text.include?(Config::DevCommands::GET_LOGS)
      @invoker.execute(GetLogsDeveloeprCommand.new(@receiver))
    elsif @message.text.include?(Config::DevCommands::REQUEST)
      @invoker.execute(RequestDeveloeprCommand.new(@receiver))
    elsif @message.text.include?(Config::DevCommands::BAN)
      @invoker.execute(BanDeveloeprCommand.new(@receiver))
    elsif @message.text.include?(Config::DevCommands::MESSAGE)
      @invoker.execute(MessageDeveloeprCommand.new(@receiver))
    end
  end
end

class Moderator < UserRole
  def execute
    super
    if @options[:message]
      if @options[:message].text == Config::BotCommands::INSPECT_NOST
        @invoker.execute(InspectNostrCommand.new(@receiver))
      elsif @options[:message].text == Config::BotCommands::AMOUNT
        @invoker.execute(AmountCommand.new(@receiver))
      end
    end
    if @verification.split(' ').first == Config::AdminStatus::DENY_REASON
      @invoker.execute(EnterRejectionReasonAction.new(@receiver))
    end
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
