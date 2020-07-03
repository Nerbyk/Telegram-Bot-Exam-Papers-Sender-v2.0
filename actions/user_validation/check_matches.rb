# frozen_string_literal: true

class ValidateUser
  def self.check_data_matches(data:)
    name = data[:name]
    link = data[:link]
    p Db::UserMessage.instance.get_name(name: name)
    p Db::UserMessage.instance.get_link(link: link)
  end
end
