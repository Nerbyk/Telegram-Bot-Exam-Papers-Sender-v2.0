# frozen_string_literal: true

require 'singleton'
require 'uri'
module Config
  class BotButtons
    ADD_ADMIN    = 'Add Admin'
    DELETE_ADMIN = 'Delete Admin'
    ADD_SUBJECT  = 'Add Subject'
    EDIT_SUBJECT = 'Delete Subject'
    START_NOSTR  = 'Start Nostrification'
    START_AD     = 'Start Ad'
    SEND_REQ     = 'Send Request'
    RESET_REQ    = 'Reset Requet'
    ACCEPT_REQ   = 'Accept Request'
    DENY_REQ     = 'Deny Request'
    BAN_REQ      = 'Ban Request'
    MENU         = 'Return to Menu'
    END_INPUT    = 'Закончить Ввод'
  end

  class BotCommands
    START            = '/start'
    STOP             = '/reset'
    MANAGE_ADMINS    = '/manage_admins'
    UPDATE_DOCUMENTS = '/update_documents'
    UPDATE_LINK      = '/change_links'
    SET_ALERT        = '/amount_to_alert'
    INSPECT_NOST     = '/inspect_nostr'
    INSPECT_BRH      = '/inspect_baraholka'
    AMOUNT           = '/amount'
    USER_STATUS      = '/status'
    ADMIN_SETTING    = '/settings'
    REQ_IN_REVIEW    = "\n\nВашу заявку в данный момент рассматривает один из модераторов, вы получите ответ в считанные минуты"
  end

  class DevCommands
    RESET = '/reset_user '
    FREEZE = '/stop_user_panel'
    GET_LOGS = '/check_logs '
    REQUEST = '/get_user_request '
    BAN = '/ban '
    MESSAGE = '/send_message '
    UPLOAD_PHOTOS = '/upload_photos'
    GET_BOT_STATUS = '/status'
  end

  class Roles
    ADMIN = 'admin'
    USER  = 'user'
    DEV   = 'developer'
    MODERATOR = 'moderator'
  end

  class Status
    LOGGED      = 'logged'
    NAME        = 'name_step'
    LINK        = 'link_step'
    SUBJECTS    = 'subjects_step'
    PHOTO       = 'photo_step'
    IN_PROGRESS = 'in_queue'
    REVIEWING   = 'review'
    ACCEPTED    = 'accepted'
    BANNED      = 'banned'
    ISCORRECT   = 'correctly?'
  end

  class AdminStatus
    MENU           = 'menu'
    ADD_ADMIN      = 'add admin'
    DELETE_ADMIN   = 'delete admin'
    ADD_SUBJECT    = 'add subject'
    DELETE_SUBJECT = 'delete subject'
    UPDATE_LINK    = 'update link'
    SET_ALERT      = 'set alert'
    DENY_REASON    = 'denying'
  end

  class Alert
    include Singleton
    attr_accessor :amount
    def initialize
      @amount = ENV['DEFAULT_ALERT']
    end
  end

  class Access
    include Singleton
    attr_accessor :user
    def initialize
      @user = true
    end
  end

  class Links
    include Singleton
    attr_accessor :vk, :telegram
    def initialize
      @vk = ENV['DEFAULT_VK']
      @telegram = ENV['DEFAULT_TG']
    end

    def set_new_link(link)
      link, community = check_link(link)
      case community
      when 'vk' then @vk = 'https://vk.com/' + link
      when 'telegram' then @telegram = 'https://t.me/' + link
      end
    end

    def get_links
      @vk + " \n\n" + @telegram
    end

    private

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
  end
end
