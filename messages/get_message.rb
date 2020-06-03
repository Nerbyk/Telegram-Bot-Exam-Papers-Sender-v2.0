# frozen_string_literal: true

require 'yaml'

class GetMessageText
  attr_reader :replies_list, :case_text, :client
  def initialize(client:)
    @client = client
    @replies_list = YAML.safe_load(File.read('./messages/msg-examples/' + client + '_messages.yml', encoding: 'utf-8'))
  end

  def reply(case_text)
    replies_list[case_text]
  end
end
