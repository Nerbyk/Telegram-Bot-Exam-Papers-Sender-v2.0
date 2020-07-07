# frozen_string_literal: true

class ValidateUser
  def self.check_data_matches(data:)
    name = data[:name]
    link = data[:link]
    name = Db::UserMessage.instance.get_name(name: name)
    link = Db::UserMessage.instance.get_link(link: link)
    if name && link
      [name, link]
    elsif name && !link
      name
    elsif !name && link
      link
    else
      false
    end
  end
end
