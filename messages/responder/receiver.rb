# frozen_string_literal: true

require './messages/inline_markup.rb'
require './messages/responder/receiver_helper.rb'
require './messages/responder/receiver_modules/admin_commands.rb'
require './messages/responder/receiver_modules/admin_actions.rb'
require './messages/responder/receiver_modules/developer_commands.rb'
require './messages/responder/receiver_modules/moderator_commands.rb'
require './actions/input_validation/check_input.rb'
require './actions/user_validation/check_matches.rb'
require './actions/telegrpah_article.rb'

class Receiver
  attr_reader :bot, :message, :my_text
  include BotActions
  def initialize(options:)
    @options = options
    @bot     = options[:bot]
    @message = options[:message]
    @my_text = options[:my_text]
  end

  # Admin commands

  include AdminCommands

  include AdminActions

  def admin_start
    send_message(text: 'greeting_menu')
    Db::User.instance.set_status(status: Config::AdminStatus::MENU, user_id: message.from.id.to_s)
  end

  # Developer commands

  include DeveloperCommands

  def developer_start
    send_message(text: 'greeting_menu')
  end

  # Moderator commands

  include ModeratorCommands

  def moderator_start
    send_message(text: 'greeting_menu')
  end

  # User panel

  def user_start
    markup = MakeInlineMarkup.new(['Билеты к Нострификации', Config::BotButtons::START_NOSTR]).get_markup
    send_message(text: 'greeting_first_time_user', markup: markup)
  end

  # Command pattern inside command pattern, idk :\
  def user_form_filling
    Form.new(options: @options).start
  end

  # Common methods
  private

  def call_menu
    Invoker.new.execute(StartCommand.new(Receiver.new(options: @options), @options))
  end

  def unexpected_message
    send_message(text: 'unexpected_message')
  end
end
