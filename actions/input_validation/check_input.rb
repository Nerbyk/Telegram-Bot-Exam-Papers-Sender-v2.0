# frozen_string_literal: true

require 'uri'
require './db/user_details.rb'
require './actions/input_validation/check_membership.rb'
class CheckUserInput
  def self.name(input:)
    input.split(' ').length == 2
  end

  def self.link(input:)
    link = input.text
    link = 'https://' + link unless link.include?('https://') || link.include?('http://')
    raise "Incorrect Link foprmat(link.include?('vk.com'))" unless link.include?('vk.com')

    link = URI.parse(link)
    raise "Incorrect Link foprmat(link.path.count('/') != 1)" unless link.path.count('/') == 1

    validation = CheckMembership.new(link_path: link.path.delete('/'))
    raise 'Membership check failed' unless validation.to_validate

    true
  rescue Exception => e
    ErrorLogDb.instance.log_error(level: inspect + '=>' + caller[0][/`.*'/][1..-2], message: input, exception: e.inspect)
    false
  end
end
