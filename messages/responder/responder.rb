# frozen_string_literal: true

require './messages/get_message.rb'
require './messages/responder/user_roles.rb'
require './db/user_config.rb'

class MessageResponder
  def initialize(options:)
    @options = options
    @message = opetions[:message]
    @role = UserConfigDb.instance.get_user_info(user_id: options[:message].from.id.to_s, user_name: options[:message].from.username)[:role]
    @my_text = GetMessageText.new(client: role.downcase)
    execute
  end

  private

  def execute
    GetUserCommand.new(role: role, options: options).call
  end

  attr_reader :role, :message_text, :options, :message, :my_text
end
