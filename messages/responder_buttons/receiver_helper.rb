# frozen_string_literal: true

# static class with help methods for button methods
class ReceiverHelper
  def self.get_list_of_admins
    array_wtih_admins = UserConfigDb.instance.get_admins
    display_string = ' '
    array_for_inline = []
    array_wtih_admins.each do |hash|
      display_string += "\n\n user id = #{hash[:user_id]} | #{hash[:user_name]}"
      array_for_inline << [hash[:user_id]]
    end
    markup = MakeInlineMarkup.new(*array_for_inline).get_board
    [display_string, array_for_inline, markup]
  end

  def self.check_add_admin_input(input)
    false if input.length != 2
    false unless input.first.to_i.is_a? Integer
    false unless input.last.to_i.is_a? String
    true
  end
end
