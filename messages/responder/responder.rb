# frozen_string_literal: true

require './messages/get_message.rb'
require './messages/responder/user_roles.rb'
require './db/user_config.rb'

class MessageResponder
  def initialize(options:)
    @options = options
    @message = options[:message]
    options[:role] = UserConfigDb.instance.get_user_info(user_id: options[:message].from.id.to_s, user_name: options[:message].from.username)[:role]
    options[:my_text] = GetMessageText.new(client: options[:role].downcase)
    execute
  end

  private

  def execute
    GetUserCommand.new(options: options).call(options)
  end

  attr_reader :message_text, :options, :message, :my_text
end
