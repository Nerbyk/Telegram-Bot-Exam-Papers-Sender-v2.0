# frozen_string_literal: true

require './actions/input_validation/check_input.rb'

class Form
  def initialize
    @user_info = {}
  end

  def start
    # initialize new user if not initialized and call method according to it's status
    send(UserConfigDb.instance.get_user_info[:status])
  end

  private

  def logged
    # changing default status
    UserConfigDb.instance.set_status(status: CfgConst::Status::NAME)
    BotOptions.instance.edit_message(text: 'guid_user_how_to_leave')
    name_step
  end

  def name_step
    BotOptions.instance.send_message(text: 'get_user_info_name')
    user_input = BotOptions.instance.get_single_input
    return_to_mainmenu if user_input.text == CfgConst::BotCommands::START
    if CheckUserInput.name(input: user_input.text)
      user_info[:name] = user_input.text
      UserConfigDb.instance.set_status(status: CfgConst::Status::LINK)
      link_step
    else
      raise 'Incorrect input format'
    end
  rescue Exception => e
    ErrorLogDb.instance.log_error(level: inpect, message: user_input, exception: e.inspect)
    BotOptions.instance.send_message(text: 'get_user_info_name_error')
    retry
  end

  def link_step
    BotOptions.instance.send_message(text: 'get_user_info_link')
    user_input = BotOptions.instance.get_single_input
    return_to_mainmenu if user_input.text == CfgConst::BotCommands::START
    if CheckUserInput.link(input: user_input)
      user_info[:link] = user_input.text
      UserConfigDb.instance.set_status(status: CfgConst::Status::SUBJECTS)
      subjects_step
    else
      raise 'Link check failed'
    end
  rescue Exception => e
    ErrorLogDb.instance.log_error(level: inspect + '=>' + caller[0][/`.*'/][1..-2], message: user_input, exception: e.inspect)
    BotOptions.instance.send_message(text: 'get_user_info_link_error')
  end

  def subjects_step; end

  def photo_step; end

  def in_queue; end

  def accepted; end

  def banned; end

  def return_to_mainmenu
    BotOptions.instance.send_message(text: 'progress_has_been_reset')
    UserConfigDb.instance.set_status(status: CfgConst::Status::LOGGED)
    sleep(1)
    Invoker.new.execute(StartCommand.new(Receiver.new))
  end

  attr_accessor :user_info
end
