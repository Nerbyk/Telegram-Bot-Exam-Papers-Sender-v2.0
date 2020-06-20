# frozen_string_literal: true

require './actions/input_validation/check_input.rb'

class Form
  include BotOptions
  def initialize(options:)
    @options = options
    @bot     = options[:bot]
    @message = options[:message]
    @my_text = options[:my_text]
    @user_id = message.from.id
    @username = message.from.username
    @user_info = {}
  end

  def start
    # initialize new user if not initialized and call method according to it's status
    send(UserConfigDb.instance.get_user_info(user_id: @user_id,
                                             user_name: @username)[:status])
  end

  private

  def logged
    # changing default status
    UserConfigDb.instance.set_status(status: CfgConst::Status::NAME, user_id: @user_id)
    edit_message(text: 'guid_user_how_to_leave')
    name_step
  end

  def name_step
    send_message(text: 'get_user_info_name')
    user_input = get_single_input
    return_to_mainmenu if user_input.text == CfgConst::BotCommands::START
    if CheckUserInput.name(input: user_input.text)
      user_info[:name] = user_input.text
      UserConfigDb.instance.set_status(status: CfgConst::Status::LINK, user_id: @user_id)
      link_step
    else
      raise 'Incorrect input format'
    end
  rescue Exception => e
    ErrorLogDb.instance.log_error(level: inspect, message: user_input, exception: e.inspect)
    send_message(text: 'get_user_info_name_error')
    retry
  end

  def link_step
    send_message(text: 'get_user_info_link')
    user_input = get_single_input
    return_to_mainmenu if user_input.text == CfgConst::BotCommands::START
    if CheckUserInput.link(input: user_input)
      user_info[:link] = user_input.text
      UserConfigDb.instance.set_status(status: CfgConst::Status::SUBJECTS, user_id: @user_id)
      subjects_step
    else
      raise 'Link check failed'
    end
  rescue Exception => e
    ErrorLogDb.instance.log_error(level: inspect + '=>' + caller[0][/`.*'/][1..-2], message: user_input, exception: e.inspect)
    markup = MakeInlineMarkup.new(['Группа ВК', CfgConst::Links.instance.vk], ['Telegram Канал', CfgConst::Links.instance.telegram]).get_link
    send_message(text: 'get_user_info_link_error', markup: markup)
    retry
  end

  def subjects_step
    available_subjects = FileConfigDb.instance.get_subjects.map(&:first)
    available_subjects = devide_subjects_for_buttons(available_subjects) << CfgConst::BotButtons::END_INPUT
    markup = MakeInlineMarkup.new(*available_subjects).get_board
    send_message(text: 'get_user_info_subjects', markup: markup)
    all_subjects = []
    loop do
      user_input = get_single_input
      if CheckUserInput.single_subject(subject: user_input, available_list: available_subjects.flatten)
        all_subjects << user_input.text
      else
        send_message(text: 'get_user_info_subjects_error_keyboard')
        raise 'Single subject check failed'
      end

      break if user_input.text == CfgConst::BotButtons::END_INPUT
    end
    all_subjects.delete(CfgConst::BotButtons::END_INPUT)
    if CheckUserInput.all_subjects(subjects: all_subjects)
      user_info[:subjects] = all_subjects
    else
      send_message(text: 'get_user_info_subjects_error')
      raise 'All subjects test failed'
    end
  rescue Exception
    retry
  end

  def photo_step; end

  def in_queue; end

  def accepted; end

  def banned; end

  def return_to_mainmenu
    send_message(text: 'progress_has_been_reset')
    UserConfigDb.instance.set_status(status: CfgConst::Status::LOGGED)
    sleep(1)
    Invoker.new.execute(StartCommand.new(Receiver.new(options: @options)))
  end

  def devide_subjects_for_buttons(subjects)
    return_array = []
    included_array = []
    (1..subjects.length).each do |i|
      case i % 2
      when 0
        included_array << subjects[i - 1]
        return_array << included_array
        included_array = []
      when 1
        included_array << subjects[i - 1]
      end
    end
    return_array
  end

  attr_accessor :user_info
  attr_reader :bot, :message, :my_text
end
