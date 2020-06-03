# frozen_string_literal: true

class Invoker
  attr_reader :history, :requests

  def execute(cmd)
    @history ||= []
    @history << cmd.execute
  end
end
