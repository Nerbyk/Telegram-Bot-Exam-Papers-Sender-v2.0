# frozen_string_literal: true

require 'uri'
require './db/user_details.rb'
require './actions/input_validation/check_membership.rb'
class CheckUserInput
  MAX_SUBJECTS = 6
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

  def self.single_subject(subject:, available_list:)
    available_list.include?(subject.text) ? true : raise('Unexpected input')
  rescue Exception => e
    ErrorLogDb.instance.log_error(level: inspect + '=>' + caller[0][/`.*'/][1..-2], message: subject, exception: e.inspect)
    false
  end

  def self.all_subjects(subjects:)
    if subjects.length > MAX_SUBJECTS || subjects.length > subjects.uniq.length
      raise
    else
      true
    end
  rescue Exception
    false
  end
end
