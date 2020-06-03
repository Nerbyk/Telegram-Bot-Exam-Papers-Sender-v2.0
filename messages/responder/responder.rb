# frozen_string_literal: true

require './messages/get_message.rb'
require './config_vars/role_state.rb'
require './messages/responder/user_roles.rb'

class MessageResponder
  def initialize(role:)
    @role = role
    @message_text = GetMessageText.new(client: role)
    execute
  end

  private

  def execute
    GetUserCommand.new(role: role).call
  end

  attr_reader :role, :message_text
end
