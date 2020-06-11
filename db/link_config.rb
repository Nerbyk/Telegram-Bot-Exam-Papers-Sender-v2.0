# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'
require 'uri'
require './db/abstract_db.rb'

class LinkConfigDb < Db
  include Singleton
  def initialize
    super
    @table          = :link_config
    @dataset        = create
  end

  def set_new_link(link)
    link, community = check_link(link)
    dataset.where(community: community).update(link: link)
  rescue StandardError
    false
  end

  private

  def create
    db.create_table? table do
      String :community
      String :link
    end
    db[table]
  end

  def check_link(link)
    community = identify_community(link)
    link = URI.parse(link)
    return false if link.path.count('/') != 1 || !community

    [link.path.delete('/'), community]
  end

  def identify_community(link)
    if link.include?('vk.com') then 'vk'
    elsif link.include?('t.me') then 'telegram'
    else false
    end
  end
  attr_reader :db, :table, :dataset
end
