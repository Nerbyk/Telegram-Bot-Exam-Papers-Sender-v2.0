# frozen_string_literal: true

class Command
  attr_reader :request
  def initialize(request)
    @request = request
  end

  def execute
    raise NotImplementedError
  end
end

class StartCommand < Command
  def execute
    command = BotOptions.instance.role.downcase + '_start'
    request.send(command)
  end
end
