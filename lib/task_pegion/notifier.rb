# frozen_string_literal: true

module TaskPegion
  # Notice to Slack
  class Notifier
    require 'uri'
    require 'net/http'
    require 'json'

    attr_reader :notification_url, :data

    def initialize(notification_url)
      @notification_url = notification_url
      @data = { 'text' => 'Hello World' }.to_json
    end

    def notice
      uri = URI.parse(notification_url)
      request = Net::HTTP::Post.new(uri)
      request.content_type = 'application/json'
      request.body = data

      # auto close if block given
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |https|
        https.request(request)
      end
    end
  end
end
