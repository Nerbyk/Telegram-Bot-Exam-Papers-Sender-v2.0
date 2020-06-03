# frozen_string_literal: true

require './db/user_config.rb'

class GetUserRole
  attr_accessor :role

  def self.user_role
    role = UserConfigDb.instance.get_role
    BotOptions.instance.role = role
    BotOptions.instance.my_text = GetMessageText.new(client: role.downcase)
    role
  end
end
