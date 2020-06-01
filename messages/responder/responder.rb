# frozen_string_literal: true

require './messages/get_message.rb'
require './config_vars/role_state.rb'

class MessageResponder
  attr_reader :role, :message_text
  def initialize(role:)
    @role = role
    @message_text = GetMessageText.new(client: role)
    execute
  end

  private

  def execute
    case role
    when Roles::ADMIN
      p role
    when Roles::USER
      p role
    when Roles::DEV
      p role
    end
  end
end
