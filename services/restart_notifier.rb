class Notifier
    def self.about_restart
        bot = BotOptions.instance.bot 
        bot.api.send_message(chat_id: ENV['ADMIN_ID'], text: "Бот был автоматически перезагружен.\nДефолтные значения:\nУведомления будут приходить от <b>#{Config::Alert.instance.amount}</b> непроверенных заявок\nВк: #{Config::Links.instance.vk}\nTG: #{Config::Links.instance.telegram}", parse_mode: 'HTML')
    end
end