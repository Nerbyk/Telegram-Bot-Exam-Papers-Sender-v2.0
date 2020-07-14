# frozen_string_literal: true

class ToRespond
  def initialize(bot:, message:)
    @bot = bot
    @message = message
    execute
  end

  private

  def execute
    options = { bot: bot, message: message }
    # begin
    case message
    when Telegram::Bot::Types::CallbackQuery
      if Config::Access.instance.user || (message.from.id == ENV['DEV_ID'].to_i || message.from.id == ENV['ADMIN_ID'].to_i)
        ButtonResponder.new(options: options).respond
      elsif !Config::Access.instance.user
        bot.api.send_message(chat_id: message.from.id, text: 'В данный момент ведутся технические работы, бот будет доступен в ближайший час.')
      end
    else
      if Config::Access.instance.user || (message.from.id == ENV['DEV_ID'].to_i || message.from.id == ENV['ADMIN_ID'].to_i)
        if message.chat.type != 'channel'
          MessageResponder.new(options: options).respond
          end # restrict access to channels
      elsif !Config::Access.instance.user
        bot.api.send_message(chat_id: message.from.id, text: 'В данный момент ведутся технические работы, бот будет доступен в ближайший час.')
      end
    end
    # rescue StandardError => e
    #     bot.api.send_message(chat_id: message.from.id, text: "Пожалуйста введите данные требуемого формата.\n\nПри возникновении трудностей свяжитесь с <a href=\"tg://user?id=143845427\">Разрабочиком</a>", parse_mode: 'HTML')
    #     Db::ErrorLog.instance.log_error(level: 'high' + '=>' + caller[0][/`.*'/][1..-2], message: message, exception: e.inspect)
    # end
  end
  attr_reader :bot, :message
end
