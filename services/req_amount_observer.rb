# frozen_string_literal: true

class Notifier
  def update
    puts "Logged #{AmountOfRequests.instance.current} uninspected requests."
    invoke_admin if AmountOfRequests.instance.current >= AmountOfRequests.instance.target
  end

  private

  def invoke_admin
    p 'all admins must be invoked'
    # TODO: Send invokation message to all moderators and admins
    # parse admins id's via get_admin method and send message via loop
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
    @target = CfgConst::Alert.instance.amount
    add_observer(Notifier.new)
  end

  def log
    @current += 1
    changed
    notify_observers(self, 1)
  end
end
