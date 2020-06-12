# frozen_string_literal: true

require 'singleton'
require 'uri'
module CfgConst
  class BotButtons
    ADD_ADMIN = 'Add Admin'
    DELETE_ADMIN = 'Delete Admin'
    ADD_SUBJECT = 'Add Subject'
    EDIT_SUBJECT = 'Delete Subject'
  end

  class BotCommands
    START = '/start'
    MANAGE_ADMINS = '/manage_admins'
    UPDATE_DOCUMENTS = '/update_documents'
    UPDATE_LINK = '/change_links'
    SET_ALERT   = '/amount_to_alert'
  end

  class Roles
    ADMIN = 'admin'
    USER  = 'user'
    DEV   = 'dev'
    MODERATOR = 'moderator'
  end

  class Alert
    include Singleton
    attr_accessor :amount
    def initialize
      @amount = 2
    end
  end

  class Links
    include Singleton
    attr_accessor :vk, :telegram
    def initialize
      @vk = 'https://vk.com/pozor.brno'
      @telegram = 'https://t.me/pozor_brno'
    end

    def set_new_link(link)
      link, community = check_link(link)
      case community
      when 'vk' then @vk = link
      when 'telegram' then @telegram = link
      end
    end

    def return_current_links
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
