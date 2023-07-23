# frozen_string_literal: true

module TaskPegion
  # Notice to Slack
  class Notifier
    require 'uri'
    require 'net/http'
    require 'json'

    attr_reader :destinations, :notice_type, :data

    def initialize(notice_type, data = { text: 'Hello World' })
      @destinations = Config.new.destinations
      @notice_type = notice_type
      @data = data.to_json
    end

    def notice
      @destinations.each do |destination|
        if destination['notice_types'].include?(@notice_type)
          uri = URI.parse(destination['url'])
          request = Net::HTTP::Post.new(uri)
          request.content_type = 'application/json'
          request.body = @data

          # auto close if block given
          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |https|
            https.request(request)
          end
          puts "#{response.body} #{response.code}"
        end
      end
    end
  end
end
