# frozen_string_literal: true

require './messages/inline_markup.rb'
require './messages/responder/receiver_helper.rb'
require './messages/responder/receiver_modules/admin_commands.rb'
require './messages/responder/receiver_modules/admin_actions.rb'
class Receiver
  attr_reader :bot, :message, :my_text
  include BotOptions
  def initialize(options:)
    @options = options
    @bot     = options[:bot]
    @message = options[:message]
    @my_text = options[:my_text]
  end

  include AdminCommands

  include AdminActions

  # include UserCommands

  # include ModeratorCommands

  # include DeveloperCommands
  # user panel
  def user_start
    markup = MakeInlineMarkup.new(['Билеты к Нострификации', 'Start Nostrification'], ['Объявление Барахолка', 'Start Ad']).get_markup
    send_message(text: 'greeting_first_time_user', markup: markup)
  end

  private

  def call_menu
    Invoker.new.execute(StartCommand.new(Receiver.new(options: @options), @options))
  end

  # Developer commands
  def developer_start
    p 'started by developer'
  end

  # Moderator commands
  def moderator_start
    p 'started by moderator'
  end
end
