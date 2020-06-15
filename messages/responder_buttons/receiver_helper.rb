# frozen_string_literal: true

# static class with help methods for button methods
class ReceiverButtonHelper
  def self.display_string(list_from_db)
    display_string = ''
    list_from_db.each do |hash|
      display_string += "\n\n #{hash.first} | #{hash.last}"
    end
    display_string
  end

  def self.markup_string(list_from_db)
    array_for_inline = []
    list_from_db.each do |row|
      array_for_inline << [row.first]
    end
    markup = MakeInlineMarkup.new(*array_for_inline).get_board
    [markup, array_for_inline]
  end

  def self.check_db_string(input)
    return false if input.length != 2
    return false unless is_number?(input.first)
    return false if is_number?(input.last)
    return false if input.nil?

    true
  end

  def self.is_number?(string)
    true if Float(string)
  rescue StandardError
    false
  end
end
