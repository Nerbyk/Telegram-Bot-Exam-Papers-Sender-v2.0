# frozen_string_literal: true

class Notifier
  attr_reader :bot
  def update
    puts "Logged #{AmountOfRequests.instance.current} uninspected requests."
    invoke_admin if AmountOfRequests.instance.current.to_i >= AmountOfRequests.instance.target.to_i
  end

  private

  include BotActions
  def invoke_admin
    @bot = BotOptions.instance.bot
    get_admins.each do |admin_id|
      # send_message(chat_id: admin_id, text: 'notification_requests', additional_text: AmountOfRequests.instance.current)
      puts "chat_id: #{admin_id}, text: 'notification_requests', additional_text: #{AmountOfRequests.instance.current}"
      send_message_parse_mode(chat_id: admin_id.to_i, text: "Кол-во непроверенных заявок - <b>#{AmountOfRequests.instance.current}</b>\n /inspect_nostr - для проверки")
    end
  end

  def get_admins
    admins = Db::User.instance.get_admins
    admins = admins.map(&:first)
    admins << ENV['ADMIN_ID']
  end
end

require 'observer'
require 'singleton'
class AmountOfRequests
  include Observable
  include Singleton
  attr_reader :current, :target
  def initialize
    @current = Db::User.instance.get_amount_in_queue
    @target = Config::Alert.instance.amount
    puts("target = #{@target}")
    puts("@current = #{@current}")
    add_observer(Notifier.new)
  end

  def log
    @current += 1
    changed
    notify_observers
  end
end
