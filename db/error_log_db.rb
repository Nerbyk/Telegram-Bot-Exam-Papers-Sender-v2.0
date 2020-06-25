# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'
require 'time'
require './db/abstract_db.rb'
class Db::ErrorLog < Db
  include Singleton
  def initialize
    super
    @table        = :error_log
    @dataset      = create
  end

  def log_error(level:, message:, exception:)
    text = message.text
    username = message.from.username
    username = 'n/a' if username.nil?
    text = 'n/a' if text.nil?
    user_info = message.from.id.to_s + ' | ' + username + ' | ' + text
    dataset.insert(timestamp: Time.now.utc.iso8601, level: level, user_info: user_info, exception_msg: exception)
  end

  private

  def create
    db.create_table? table do
      primary_key :id
      String :timestamp
      String :level
      String :user_info
      String :exception_msg
    end
    db[table]
  end
  attr_reader :db, :table, :dataset
end
