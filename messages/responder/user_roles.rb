# frozen_string_literal: true

# abstract class
class UserRole
  def self.excute
    raise NotImplementedError
  end
end

# invoker classes to command pattern
class User < UserRole
  def self.execute
    p 'user'
  end
end

class Admin < UserRole
  def self.execute
    p 'admin'
  end
end

class Developer < UserRole
  def self.execute
    p 'developer'
  end
end

class GetUserCommand
  def call(role:)
    @role = role
    find_role_commands.execute
  end

  def find_role_commands
    Kernel.const_get(role)
  end
  attr_reader :role
end
