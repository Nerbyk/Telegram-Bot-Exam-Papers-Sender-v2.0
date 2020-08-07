# frozen_string_literal: true

require 'uri'
require './actions/input_validation/check_membership.rb'
class CheckUserInput
  MAX_SUBJECTS = 6 # more than 6 subjects cannot be assigned to students
  def self.name(input:)
    if input.text.split(' ').length == 2
      true
    else
      raise 'Incorrect input format'
    end
  rescue Exception => e
    to_log(level: inspect, exception: e, user_input: input)
    # Db::ErrorLog.instance.log_error(level: inspect + '=>' + caller[0][/`.*'/][1..-2], message: input, exception: e.inspect)
    false
  end

  def self.link(input:, options:)
    link = input.text
    link = 'https://' + link unless link.include?('https://') || link.include?('http://')
    raise "Incorrect Link foprmat(link.include?('vk.com'))" unless link.include?('vk.com')

    link = URI.parse(link)
    raise "Incorrect Link foprmat(link.path.count('/') != 1)" unless link.path.count('/') == 1

    validation = CheckMembership.new(link_path: link.path.delete('/'), options: options)
    raise 'Membership check failed' unless validation.to_validate

    true
  rescue Exception => e
    to_log(level: inspect, exception: e, user_input: input)
    false
  end

  def self.single_subject(input:, available_list:)
    available_list << Config::BotCommands::STOP
    available_list.include?(input.text) ? true : raise('Unexpected input')
  rescue Exception => e
    to_log(level: inspect, exception: e, user_input: input)
    false
  end

  def self.all_subjects(input:)
    input = input.split(';')
    if input.length > MAX_SUBJECTS || input.length > input.uniq.length
      raise 'Single subject check failed'
    else
      true
    end
  rescue Exception => e
    to_log(level: inspect, exception: e, user_input: nil)
    false
  end

  def self.check_photo_format(input:)
    if input.photo == []
      raise 'Incorrect message format'
    else
      true
    end
  rescue Exception => e
    to_log(level: inspect, exception: e, user_input: input)
    false
  end

  def self.check_courses(input:)
    raise 'incorrect input format' if input.text == nil
    raise 'user input is too long' if input.text.length > 255 
    true 
  rescue Exception => e  
    to_log(level: inspect, exception: e, user_input: input)
    false 
  end

  def self.to_log(level:, exception:, user_input:)
    Db::ErrorLog.instance.log_error(level: level + '=>' + caller[0][/`.*'/][1..-2], message: user_input, exception: exception.inspect)
  end
end
