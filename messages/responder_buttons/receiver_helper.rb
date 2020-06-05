# frozen_string_literal: true

# static class with help methods for button methods
class ReceiverHelper
  def self.display_string(list_from_db)
    display_string = ''
    array_for_inline = []
    list_from_db.each do |hash|
      display_string += "\n\n user id = #{hash.first} | #{hash.last}"
      array_for_inline << [hash.first]
    end
    markup = MakeInlineMarkup.new(*array_for_inline).get_board
    [display_string, list_from_db, markup]
  end

  def self.check_string_length(input)
    return false if input.length != 2
    return false unless is_number?(input.first)
    return false if is_number?(input.last)

    true
  end

  def self.is_number?(string)
    true if Float(string)
  rescue StandardError
    false
  end
end
