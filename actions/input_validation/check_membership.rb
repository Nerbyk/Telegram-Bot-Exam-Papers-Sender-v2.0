# frozen_string_literal: true

require 'vkontakte_api'
require 'uri'
class CheckMembership
  def initialize(link_path:, options:)
    @link_path    = link_path
    @options      = options
    @user_id      = options[:message].from.id
    @token        = ENV['VK_TOKEN']
    @version      = ENV['VK_API_VERSION']
    @vk           = VkontakteApi::Client.new(token)
    @group_id     = get_vk_path
    @community_id = get_telegram_path
  end

  def to_validate
    link_path = get_numeric_user_id
    vk_status = vk.groups.isMember('v' => version, 'group_id' => group_id, 'user_id' => link_path.to_i)
    vk_status = vk_status == 1
    telegram_status = @options[:bot].api.getChatMember(chat_id: '@' + community_id, user_id: @user_id)
    p telegram_status['result']['status']
    telegram_status = if telegram_status['result']['status'] == 'member' || telegram_status['result']['status'] == 'administrator'
                        true
                      else
                        false
                      end
    vk_status == telegram_status
  end

  private

  def get_vk_path
    link = URI.parse(Config::Links.instance.vk)
    link.path.delete('/')
  end

  def get_telegram_path
    link = URI.parse(Config::Links.instance.telegram)
    link.path.delete('/')
  end

  def get_numeric_user_id
    if link_path.include?('id')
      link_path.delete('id').to_i
    else
      numeric_id = vk.users.get("v": version, "user_ids": link_path, "fields": 'id')
      numeric_id[0]['id']
    end
  end

  def is_int?
    true if Int(@link)
  rescue StandardError
    false
  end

  attr_reader :link_path, :token, :version, :vk, :group_id, :community_id
end
