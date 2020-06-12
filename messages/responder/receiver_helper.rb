# frozen_string_literal: true

class ReceiverHelper
  def self.choose_option_msg(*buttons)
    each_button = []
    (0..buttons.length - 1).each do |i|
      each_button << buttons[i]
    end
    inline_buttons = MakeInlineMarkup.new(*each_button).get_markup
    BotOptions.instance.send_message(text: 'choose_option', markup: inline_buttons)
  end

  def self.is_number?(string)
    true if Float(string)
  rescue StandardError
    false
  end
end
