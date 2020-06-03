# frozen_string_literal: true

require './db/user_config.rb'

class GetUserRole
  attr_accessor :role

  def self.user_role
    role = UserConfigDb.instance.get_role
    BotOptions.instance.role = role
    role
  end
end
