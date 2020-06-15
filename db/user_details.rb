# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'

require './db/abstract_db.rb'

class UserDetailsNostr < Db
  include Singleton
  def initialize
    super
    @table          = :user_details_nostr
    @dataset        = create
  end

  # return false if row with specific data(link) exists

  private

  def create
    db.create_table? table do
      primary_key :id
      String :user_id
      String :user_name
      String :name
      String :link
      String :subjects
      String :image
      String :status
    end
    db[table]
  end

  attr_reader :db, :table, :dataset
end
