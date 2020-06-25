# frozen_string_literal: true

require './messages/get_message.rb'
require './messages/responder/user_roles.rb'

class MessageResponder
  def initialize(options:)
    @options = options
    @message = options[:message]
    options[:role] = Db::UserConfig.instance.get_user_info(user_id: options[:message].from.id.to_s, user_name: options[:message].from.username)[:role]
    options[:my_text] = GetMessageText.new(client: options[:role].downcase)
  end

  def respond
    GetUserCommand.new(options: options).call(options)
  end

  private

  attr_reader :message_text, :options, :message, :my_text
end
