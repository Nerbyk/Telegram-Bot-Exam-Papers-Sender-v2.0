# frozen_string_literal: true

require './messages/responder/receiver.rb'
require './messages/responder/commands.rb'
require './messages/responder/invoker.rb'
# abstract class
class UserRole
  def initialize
    @receiver = Receiver.new
    @invoker  = Invoker.new
  end

  # common comands
  def execute
    case BotOptions.instance.message.text
    when '/start' then @invoker.execute(StartCommand.new(@receiver))
    end
  end
end

# invoker classes to command pattern
class User < UserRole
  def execute
    super
  end
end

class Admin < UserRole
  def execute
    super
  end
end

class Developer < UserRole
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
    Kernel.const_get(role)
  end
  attr_reader :role
end
