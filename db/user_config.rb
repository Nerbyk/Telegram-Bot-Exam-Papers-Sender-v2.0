# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'

require './db/abstract_db.rb'
class UserConfigDb < Db
  include Singleton
  def initialize
    super
    @table        = :user_config
    @dataset      = create
    @default_role = CfgConst::Roles::USER
  end

  def get_role
    check_existance || initialize_user
  end

  def add_admin(input:)
    new_role = CfgConst::Roles::MODERATOR
    if check_existance(user_id: input.first)
      dataset.where(user_id: input.first).update(role: new_role)
    else
      initialize_user(user_id: input.first, user_name: input.last, role: new_role)
    end
  end

  def get_admins
    return_array = []
    dataset.each do |row|
      return_array << row if row[:role].include?(CfgConst::Roles::MODERATOR)
    end
    p return_array
    return_array
  end

  def delete_admin(user_id)
    dataset.where(user_id: user_id).update(role: CfgConst::Roles::USER)
  rescue StandardError
    false
  end

  private

  def check_existance(user_id: BotOptions.instance.message.from.id.to_s)
    check = dataset.where(user_id: user_id).first[:role]
  rescue NoMethodError # if another type of error -> error in main exeception handling
    false
  else
    check
  end

  def initialize_user(role: default_role, user_id: BotOptions.instance.message.from.id.to_s, user_name: BotOptions.instance.message.from.username)
    dataset.insert(user_id: user_id,
                   user_name: user_name,
                   role: role,
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
