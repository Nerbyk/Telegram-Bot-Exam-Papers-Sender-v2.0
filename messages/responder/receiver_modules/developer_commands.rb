module DeveloperCommands
    def reset_dev
        user_id = message.text.split(' ').last.to_i
        Db::UserMessage.instance.del_row(user_id: user_id)
        Db::User.instance.set_status(user_id: user_id, status: Config::Status::LOGGED)
        Db::User.instance.delete_admin(user_id)
        send_message_parse_mode(text: "User <a href=\"tg://user?id=#{user_id.to_s}\">#{user_id.to_s}</a> progress has been reset")
    rescue => e  
        exception_dev(e)
    end

    def freeze_dev
        Config::Access.instance.user ? Config::Access.instance.user = false : Config::Access.instance.user = true
        send_message_text(text: "State was changed to #{Config::Access.instance.user}")
    rescue => e  
        exception_dev(e)
    end

    def get_logs_dev
        num = message.text.split(' ').last.to_i
        logs = Db::ErrorLog.instance.return_last_logs(num: num)
        to_display = []
        logs.each do |element|
            to_display << element.inspect
        end
        send_message_text(text: to_display.join("\n\n"))
    rescue => e  
        exception_dev(e)
    end

    def request_dev
        user_id = message.text.split(' ').last
        user_request = Db::UserMessage.instance.get_user_data(user_id: user_id.to_i) 
        request_text = "\tЗаявка №#{user_request[:user_id].to_s}\nTG ID: <a href=\"tg://user?id=#{user_request[:user_id].to_s}\">#{user_request[:user_id].to_s}</a>\nИмя и Фамилия: #{user_request[:name]}\nСсылка ВК: #{user_request[:link]}\nПредметы: #{user_request[:subjects].gsub(';', ' ')}"
        send_photo_parse_mode(photo: user_request[:photo].split(';').first,text: request_text)
    rescue => e  
        exception_dev(e)
    end

    def ban_dev
        user_id = message.text.split(' ').last.to_i 
        Db::User.instance.set_status(uer_id: user_id, status: Config::Status::BANNED)
    rescue => e  
        exception_dev(e)
    end

    def message_dev
        user_id = message.text.split(' ')[1]
        text = message.text.split(' ').last
        send_message_text(chat_id: user_id.to_i, text: "Сообщение от разработчика: \n" + text)
    rescue => e  
        exception_dev(e)
    end

    def exception_dev(e) 
        send_message_text(text: "#{e.inspect}\n#{caller[0][/`.*'/][1..-2]}")
    rescue => e  
        exception_dev(e)
    end
end