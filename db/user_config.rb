# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'

class UserConfigDb
  include Singleton
  def initialize
    @db           = Sequel.sqlite('./db/user_config.db')
    @table        = :user_config
    @dataset      = create
    @default_role = 'User'
  end

  def get_role
    check_existance || initialize_user
  end

  private

  def check_existance
    p "message from id in check_existance: #{BotOptions.instance.message.from.id}"
    dataset.each do |row|
      p " row role #{row[:role]}"
      return row[:role] if row[:user_id] == BotOptions.instance.message.from.id.to_s
    end
    false
  end

  def initialize_user
    p "initialuze_user called by #{BotOptions.instance.message.from.id}"
    dataset.insert(user_id: BotOptions.instance.message.from.id.to_s,
                   user_name: BotOptions.instance.message.from.username,
                   role: default_role,
                   status: 'Registered')
    default_role
  end

  def create
    db.create_table? table do
      primary_key :id
      String :user_id
      String :user_name
      String :role
      String :status
      index :user_id, unique: true
    end
    db[table]
  end
  attr_reader :db, :table, :dataset, :default_role
end
