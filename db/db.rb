# frozen_string_literal: true

require 'singleton'
require 'sequel'
require 'sqlite3'
require 'time'

module Db
  class ErrorLog
    include Singleton
    def initialize
      @table = :error_log
      @dataset = create
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
      DB.create_table? table do
        primary_key :id
        String :timestamp
        String :level
        String :user_info
        String :exception_msg
      end
      DB[table]
    end
    attr_reader :table, :dataset
  end

  class FileConfig
    include Singleton
    def initialize
      @table      = :file_config
      @dataset    = create
    end

    def set_subject(subject:, message_id:)
      create_or_update = dataset.where(subject: subject)
      if create_or_update.update(subject: subject, message_id: message_id) != 1
        dataset.insert(subject: subject, message_id: message_id)
      end
    end

    def get_subjects
      cols = %i[subject message_id]
      dataset.select { cols }.collect { |h| cols.collect { |c| h[c] } }
    end

    def delete_subject(subject)
      dataset.where(subject: subject).delete
    rescue StandardError
      false
    end

    private

    def create
      DB.create_table? table do
        primary_key :id
        String :subject
        String :message_id
      end
      DB[table]
    end
    attr_reader :table, :dataset
  end

  class UserDetailsNostr
    include Singleton
    def initialize
      @table          = :user_details_nostr
      @dataset        = create
    end

    # return false if row with specific data(link) exists

    private

    def create
      DB.create_table? table do
        primary_key :id
        String :user_id
        String :user_name
        String :name
        String :link
        String :subjects
        String :image
        String :status
      end
      DB[table]
    end

    attr_reader :table, :dataset
  end

  class UserConfig
    include Singleton
    def initialize
      @table        = :user_config
      @dataset      = create
      @default_role = CfgConst::Roles::USER
    end

    def get_user_info(user_id:, user_name:, role: default_role)
      create_or_return = dataset.where(user_id: user_id)
      if create_or_return.update(user_id: user_id) != 1
        dataset.insert(user_id: user_id,
                       user_name: user_name,
                       role: role,
                       status: CfgConst::Status::LOGGED)
        return create_or_return.first
      end
      create_or_return.first
    end

    def set_status(status:, user_id:)
      dataset.where(user_id: user_id).update(status: status)
    end

    def add_admin(input:)
      new_role = CfgConst::Roles::MODERATOR
      # initialize new user, if not created
      get_user_info(user_id: input.first, user_name: input.last, role: new_role)
      dataset.where(user_id: input.first).update(role: new_role)
    end

    def get_admins
      return_array = []
      dataset.each do |row|
        next unless row[:role].include?(CfgConst::Roles::MODERATOR)

        spec_data = []
        spec_data << row[:user_id]
        spec_data << row[:user_name]
        return_array << spec_data
      end
      return_array
    end

    def delete_admin(user_id)
      dataset.where(user_id: user_id).update(role: CfgConst::Roles::USER)
    rescue StandardError
      false
    end

    private

    def create
      DB.create_table? table do
        primary_key :id
        String :user_id
        String :user_name
        String :role
        String :status
        index :user_id, unique: true
      end
      DB[table]
    end
    attr_reader :table, :dataset, :default_role
  end

  class TempUserInfo
    include Singleton
    def initialize
      @table = :temp_info
      @dataset = create
    end

    def set_name(user_id:, name:)
      dataset.where(user_id: user_id).update(name: name)
    end

    def set_link(user_id:, link:)
      dataset.where(user_id: user_id).update(link: link)
    end

    def set_subject(user_id:, subject:)
      subject += ';'
      datset.where(user_id: user_id).insert(subjects: subject)
    end

    def get_subjects(user_id:)
      p dataset.where(user_id: user_id)
    end

    def del_row(user_id:)
      dataset.where(user_id: user_id).delete
    end

    private

    def create
      DB.create_table? table do
        primary_key :id
        String :user_id
        String :name
        String :link
        String :subjects
        String :photo
      end
      DB[table]
    end
    attr_reader :dataset, :table
  end

  DB = Sequel.sqlite('./db/user_config.db')
end
