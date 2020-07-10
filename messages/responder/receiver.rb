# frozen_string_literal: true

require './messages/inline_markup.rb'
require './messages/responder/receiver_helper.rb'
require './messages/responder/receiver_modules/admin_commands.rb'
require './messages/responder/receiver_modules/admin_actions.rb'
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

  include AdminCommands

  include AdminActions

  def user_start
    markup = MakeInlineMarkup.new(['Билеты к Нострификации', Config::BotButtons::START_NOSTR]).get_markup
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
    inspectable_user_id = inspectable_user[:user_id]
    Db::User.instance.set_status(status: Config::Status::REVIEWING + ' ' + admin_name,
                                 user_id: inspectable_user_id)
    user_data = Db::UserMessage.instance.get_user_data(user_id: inspectable_user_id)
    request_text = "\tЗаявка №#{inspectable_user_id}\nTG ID: <a href=\"tg://user?id=#{inspectable_user_id}\">#{inspectable_user_id}</a>\nИмя и Фамилия: #{user_data[:name]}\nСсылка ВК: #{user_data[:link]}\nПредметы: #{user_data[:subjects].gsub(';', ' ')}"

    matches_warning_text = "\n\n"
    matched_name, matched_link = ValidateUser.check_data_matches(data: user_data)
    if matched_link || matched_name
      links_to_articles = GenerateArticleLink.new(matched_name, matched_link).create_article
      if links_to_articles.is_a?(Array)
        matches_warning_text += "<b>Имя пользователя совпало с другой заявкой!</b> - <a href=\"#{links_to_articles.first}\">Посмотреть Заявку</a>\n" +
                                "<b>Ссылка на ва совпала с другой заявкой!</b> - <a href=\"#{links_to_articles.last}\">Посмотреть Заявку</a>\n"
      elsif links_to_articles.is_a?(String)
        puts links_to_articles
        matches_warning_text += "<b>Имя пользователя или ВК совпало с другой заявкой!</b> - <a href=\"#{links_to_articles}\">Посмотреть Заявку</a>\n"
      end
    end
    markup = MakeInlineMarkup.new(['Одобрить', Config::BotButtons::ACCEPT_REQ], ['Отказать', Config::BotButtons::DENY_REQ], ['Забанить', Config::BotButtons::BAN_REQ], ['Вернуться в Главное меню', Config::BotButtons::MENU]).get_markup
    send_photo_parse_mode(text: request_text + matches_warning_text,
                          photo: user_data[:photo].split(';').first,
                          markup: markup)
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
