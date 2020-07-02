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
  end

  def start
    # initialize new user if not initialized and call method according to it's status
    send(Db::User.instance.get_user_info(user_id: @user_id,
                                         user_name: @username)[:status])
  end

  def logged
    # changing default status
    send_message(text: 'guid_user_how_to_leave')
    name_step_trigger
  end

  def name_step
    user_input = message
    if user_input.text == CfgConst::BotCommands::STOP
      return_to_mainmenu
      return
    end

    if CheckUserInput.name(input: user_input)
      Db::UserMessage.instance.set_name(user_id: @user_id, name: user_input.text)
      link_step_trigger
    else
      send_message(text: 'get_user_info_name_error')
    end
  end

  def link_step
    # send_message(text: 'get_user_info_link')
    user_input = message

    if user_input.text == CfgConst::BotCommands::STOP
      return_to_mainmenu
      return
    end

    if CheckUserInput.link(input: user_input, options: @options)
      Db::UserMessage.instance.set_link(user_id: @user_id, link: user_input.text)
      subject_step_trigger
    else
      raise 'Link check failed'
    end
  rescue Exception
    markup = MakeInlineMarkup.new(['Группа ВК', CfgConst::Links.instance.vk], ['Telegram Канал', CfgConst::Links.instance.telegram]).get_link
    send_message(text: 'get_user_info_link_error', markup: markup)
  end

  def subjects_step
    user_input = message
    available_subjects = Db::FileConfig.instance.get_subjects.map(&:first)
    available_subjects = devide_subjects_for_buttons(available_subjects) << CfgConst::BotButtons::END_INPUT
    if user_input.text == CfgConst::BotCommands::STOP
      return_to_mainmenu
      return
    end

    if user_input.text != CfgConst::BotButtons::END_INPUT
      if CheckUserInput.single_subject(input: user_input, available_list: available_subjects.flatten)
        Db::UserMessage.instance.set_subject(user_id: @user_id, subject: user_input.text)
      else
        markup = subject_keyboard
        send_message(text: 'get_user_info_subjects_error_keyboard', markup: markup)
      end
    else
      all_subjects = Db::UserMessage.instance.get_subjects(user_id: @user_id.to_s).split(';')
      if CheckUserInput.all_subjects(input: all_subjects)
        photo_step_trigger
      else
        send_message(text: 'get_user_info_subjects_error')
        Db::UserMessage.instance.del_subjects(user_id: @user_id)

      end
    end
  end

  def photo_step
    user_input = message

    if user_input.text == CfgConst::BotCommands::STOP
      return_to_mainmenu
      return
    end

    if CheckUserInput.check_photo_format(input: user_input)
      photo = bot.api.get_updates.dig('result', 0, 'message', 'photo', -1, 'file_id')
      Db::UserMessage.instance.set_photo(user_id: @user_id, photo: photo)
      acceptance_step_markup
    else
      send_message(text: 'get_user_info_image_error')
    end
  end

  def correctly?
    p 'get input'
  end

  def in_queue
    send_message(text: 'request_sent')
  end

  def accepted; end

  def banned; end

  private

  # methods to trigger user to send a message and change status in DB
  # due functionality of tg need to implement this methods
  # (first you get the user data and then u process this data)
  def name_step_trigger
    Db::User.instance.set_status(status: CfgConst::Status::NAME, user_id: @user_id)
    Db::UserMessage.instance.set_user(user_id: @user_id.to_s)
    send_message(text: 'get_user_info_name')
  end

  def link_step_trigger
    Db::User.instance.set_status(status: CfgConst::Status::LINK, user_id: @user_id)
    send_message(text: 'get_user_info_link')
  end

  def subject_step_trigger
    Db::User.instance.set_status(status: CfgConst::Status::SUBJECTS, user_id: @user_id)
    markup = subject_keyboard
    send_message(text: 'get_user_info_subjects', markup: markup)
  end

  def photo_step_trigger
    Db::User.instance.set_status(status: CfgConst::Status::PHOTO, user_id: @user_id)
    markup = MakeInlineMarkup.delete_board
    send_message(text: 'get_user_info_image', markup: markup)
  end

  def acceptance_step_markup
    Db::User.instance.set_status(status: CfgConst::Status::ISCORRECT, user_id: @user_id)
    markup = MakeInlineMarkup.new(['Отправить Заявку', CfgConst::BotButtons::SEND_REQ],
                                  ['Заполнить Заного', CfgConst::BotButtons::RESET_REQ]).get_markup
    user_data = Db::UserMessage.instance.get_user_data(user_id: @user_id)
    photo = user_data[:photo]
    user_info = 'Имя и Фамилия: ' + user_data[:name] + "\n" + 'Предметы: ' + user_data[:subjects].split(';').join(' ')
    send_photo(text: 'acceptance_step_show_info',
               additional_text: user_info,
               photo: photo,
               markup: markup)
  end

  # some class helper methods to interact with user and data he passes
  def subject_keyboard
    available_subjects = Db::FileConfig.instance.get_subjects.map(&:first)
    available_subjects = devide_subjects_for_buttons(available_subjects) << CfgConst::BotButtons::END_INPUT
    MakeInlineMarkup.new(*available_subjects).get_board
  end

  def return_to_mainmenu
    markup = MakeInlineMarkup.delete_board
    send_message(text: 'progress_has_been_reset', markup: markup)
    Db::User.instance.set_status(status: CfgConst::Status::LOGGED, user_id: @user_id)
    sleep(1)
    Invoker.new.execute(StartCommand.new(Receiver.new(options: @options), @options))
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
    return_array << subjects.last if subjects.length.odd?
    return_array
  end

  attr_reader :bot, :message, :my_text
end
