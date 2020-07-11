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
      if message.nil?
        user_info = 'n/a'
      else
        text = message.text
        username = message.from.username
        username = 'n/a' if username.nil?
        text = 'n/a' if text.nil?
        user_info = message.from.id.to_s + ' | ' + username + ' | ' + text
      end

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

    def get_message_id(subject:)
      dataset.where(subject: subject).first[:message_id]
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

  class User
    include Singleton
    def initialize
      @table        = :user_config
      @dataset      = create
      @default_role = Config::Roles::USER
      initialize_admin 
      # initialize_dev
    end

    def initialize_admin
      create_users = dataset.where(user_id: ENV['ADMIN_ID'])
      if create_users.update(user_id: ENV['ADMIN_ID']) != 1 
        dataset.insert(user_id: ENV['ADMIN_ID'], 
                       user_name: 'Admin',
                       role: Config::Roles::ADMIN,
                       status: Config::AdminStatus::MENU)
      end
    end

    def initialize_dev 
      create_users = dataset.where(user_id: ENV['DEV_ID'])
      if create_users.update(user_id: ENV['DEV_ID']) != 1 
        dataset.insert(user_id: ENV['DEV_ID'], 
                       user_name: 'Developer',
                       role: Config::Roles::DEV,
                       status: Config::AdminStatus::MENU)
      end
    end

    def get_user_info(user_id:, user_name:, role: default_role)
      create_or_return = dataset.where(user_id: user_id)
      if create_or_return.update(user_id: user_id) != 1
        dataset.insert(user_id: user_id,
                       user_name: user_name,
                       role: role,
                       status: Config::Status::LOGGED)
        return create_or_return.first
      end
      create_or_return.first
    end

    def set_status(status:, user_id:)
      dataset.where(user_id: user_id).update(status: status)
    end

    def add_admin(input:)
      new_role = Config::Roles::MODERATOR
      # initialize new user, if not created
      get_user_info(user_id: input.first, user_name: input.last, role: new_role)
      dataset.where(user_id: input.first).update(role: new_role, user_name: input.last)
    end

    def get_admins
      return_array = []
      dataset.each do |row|
        next unless row[:role].include?(Config::Roles::MODERATOR)

        spec_data = []
        spec_data << row[:user_id]
        spec_data << row[:user_name]
        return_array << spec_data
      end
      return_array
    end

    def get_admin_name(user_id:)
      dataset.where(user_id: user_id).first[:user_name]
    end

    def delete_admin(user_id)
      dataset.where(user_id: user_id).update(role: Config::Roles::USER)
    rescue StandardError
      false
    end

    def get_amount_in_queue
      dataset.where(status: Config::Status::IN_PROGRESS).count
    end

    def get_position_in_queue(user_id:)
      counter = 0
      dataset.each do |row|
        counter += 1 if row[:status] == Config::Status::IN_PROGRESS && row[:user_id] != user_id
        return false if row[:status] == Config::Status::REVIEWING && row[:user_id] == user_id
        return counter if row[:status] == Config::Status::IN_PROGRESS && row[:user_id] == user_id
      end
      counter
    end

    def get_queued_user(admin_name:)
      if dataset.where(status: Config::Status::REVIEWING + ' ' + admin_name).first.nil?
        return false if dataset.where(status: Config::Status::IN_PROGRESS).first.nil?

        dataset.where(status: Config::Status::IN_PROGRESS).first
      else
        dataset.where(status: Config::Status::REVIEWING + ' ' + admin_name).first
      end
    end

    def return_to_subject
      dataset.where(status: [Config::Status::SUBJECTS, Config::Status::PHOTO, Config::Status::ISCORRECT]).update(status: Config::Status::LOGGED)
    end

    private

    def create
      DB.create_table? table do
        primary_key :user_id, keep_order: false
        String :user_name
        String :role
        String :status
      end
      DB[table]
    end
    attr_reader :table, :dataset, :default_role
  end

  class UserMessage
    include Singleton
    def initialize
      @table = :temp_info
      @dataset = create
    end

    def set_user(user_id:)
      if dataset.where(user_id: user_id).update(user_id: user_id) != 1
        dataset.insert(user_id: user_id, created: Date.today)
      end
    end

    def set_name(user_id:, name:)
      dataset.where(user_id: user_id).update(name: name)
    end

    def set_link(user_id:, link:)
      dataset.where(user_id: user_id).update(link: link)
    end

    def set_subject(user_id:, subject:)
      subject += ';'
      saved_subjects = dataset.where(user_id: user_id).first[:subjects]
      saved_subjects = '' if saved_subjects.nil?
      saved_subjects += subject
      dataset.where(user_id: user_id).update(subjects: saved_subjects)
    end

    def get_subjects(user_id:)
      dataset.where(user_id: user_id).first[:subjects]
    end

    def del_subjects(user_id:)
      dataset.where(user_id: user_id).update(subjects: nil)
    end

    def set_photo(user_id:, photo:)
      dataset.where(user_id: user_id).update(photo: photo)
    end

    def del_row(user_id:)
      dataset.where(user_id: user_id).delete
    end

    def reset_row(user_id:)
      dataset.where(user_id: user_id).update(created: nil,
                                             name: nil,
                                             link: nil,
                                             subjects: nil,
                                             photo: nil)
    end

    def get_user_data(user_id:)
      dataset.where(user_id: user_id).first
    end

    def get_name(name:)
      dataset.join(:user_config, user_id: :user_id).where(name: name, status: Config::Status::ACCEPTED).first
    end

    def get_link(link:)
      dataset.join(:user_config, user_id: :user_id).where(link: link, status: Config::Status::ACCEPTED).first
    end

    private

    def create
      DB.create_table? table do
        foreign_key :user_id, :user_config
        Date   :created
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
