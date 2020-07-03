# frozen_string_literal: true

require './messages/inline_markup.rb'
require './messages/responder/receiver_helper.rb'
require './messages/responder/receiver_modules/admin_commands.rb'
require './messages/responder/receiver_modules/admin_actions.rb'
require './actions/input_validation/check_input.rb'
require './actions/user_validation/check_matches.rb'

class Receiver
  attr_reader :bot, :message, :my_text
  include BotActions
  def initialize(options:)
    @options = options
    @bot     = options[:bot]
    @message = options[:message]
    @my_text = options[:my_text]
  end

  include AdminCommands

  include AdminActions

  def user_start
    markup = MakeInlineMarkup.new(['Билеты к Нострификации', Config::BotButtons::START_NOSTR],
                                  ['Объявление Барахолка', Config::BotButtons::START_AD]).get_markup
    send_message(text: 'greeting_first_time_user', markup: markup)
  end

  def unexpected_message
    send_message(text: 'unexpected_message')
  end

  def user_form_filling
    Form.new(options: @options).start
  end

  # include UserCommands

  # include ModeratorCommands
  def inspect_nostr
    admin_name = Db::User.instance.get_admin_name(user_id: message.from.id)
    inspectable_user = Db::User.instance.get_queued_user(admin_name: admin_name)
    unless inspectable_user
      send_message(text: 'no_requests')
      sleep(1)
      call_menu
      return
    end
    inspectable_user_name = if inspectable_user[:user_name].nil?
                              'N/A'
                            else
                              "@#{inspectable_user[:user_name]}"
                            end
    inspectable_user_id = inspectable_user[:user_id]
    Db::User.instance.set_status(status: Config::Status::REVIEWING + ' ' + admin_name,
                                 user_id: inspectable_user_id)
    user_data = Db::UserMessage.instance.get_user_data(user_id: inspectable_user_id)
    demonstrate_msg = inspectable_user_id.to_s + "\nTG ID: " +
                      inspectable_user_name + "\nИмя и Фамилия: " +
                      user_data[:name] + "\nСсылка ВК: " +
                      user_data[:link] + "\nПредметы: " + user_data[:subjects].gsub(';', ' ')
    ValidateUser.check_data_matches(data: user_data)
    send_message(text: 'request', additional_text: demonstrate_msg)
  end
  # include DeveloperCommands
  # user panel

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
    send_message(text: 'greeting_menu')
  end
end
