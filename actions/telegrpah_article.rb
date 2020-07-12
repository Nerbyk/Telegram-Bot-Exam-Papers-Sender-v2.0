# frozen_string_literal: true

require 'telegraph-ruby'

class GenerateArticleLink
  def initialize(*matched_requests)
    @matched_requests = matched_requests
    @telegraph = Telegraph.new
    @token = telegraph.createAccount(short_name: 'PozorBot')['access_token']
  end

  def create_article
    return_links = matched_requests.compact.map do |request|
      user_id = request[:user_id]
      user_name = request[:name]
      user_link = request[:link]
      request_data = request[:created].to_s
      user_subjects = request[:subjects].gsub(';', ' ')
      user_photo = "https://api.telegram.org/file/bot#{ENV['TOKEN']}/#{request[:photo].split(';').last}"
      page = telegraph.createPage(access_token: token,
                                  title: "Заявка №#{user_id}",
                                  content: "[{\"tag\":\"figure\",
                                \"children\":[
                                {\"tag\":\"img\",\"attrs\":{\"src\":\"#{user_photo}\"}},
                                {\"tag\":\"figcaption\",\"children\":[\"\"]}]},
                                {\"tag\":\"p\", \"children\":[\"Дата Подачи: #{request_data}\nИмя и Фамилия: #{user_name}\nСсылка ВК: #{user_link}\nПредметы: #{user_subjects}\"]}]")
      page['url']
    end
    return_links.length == 1 ? return_links.first : return_links
  end

  private

  attr_reader :matched_requests, :token, :telegraph
end
