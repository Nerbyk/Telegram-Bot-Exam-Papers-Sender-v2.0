# frozen_string_literal: true

class Notifier
  def update
    puts "Logged #{AmountOfRequests.instance.current} uninspected requests."
    invoke_admin if AmountOfRequests.instance.current >= AmountOfRequests.instance.target
  end

  private

  include BotActions
  def invoke_admin
    get_admins.each do |admin_id|
      # send_message(chat_id: admin_id, text: 'notification_requests', additional_text: AmountOfRequests.instance.current)
      puts "chat_id: #{admin_id}, text: 'notification_requests', additional_text: #{AmountOfRequests.instance.current}"
    end
  end

  def get_admins
    admins = Db::User.instance.get_admins << [12_345, 'NameNick']
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
