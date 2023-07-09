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
  end
end
