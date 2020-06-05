# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'

require './db/abstract_db.rb'
class FileConfigDb < Db
  include Singleton
  def initialize
    super
    @table      = :file_config
    @dataset    = create
  end

  def set_subject(subject:, message_id:)
    create_or_update = dataset.where(subject: subject)
    p subject
    if create_or_update.update(subject: subject, message_id: message_id) != 1
      dataset.insert(subject: subject, message_id: message_id)
    end
  end

  private

  def create
    db.create_table? table do
      primary_key :id
      String :subject
      String :message_id
    end
    db[table]
  end
  attr_reader :db, :table, :dataset
end
