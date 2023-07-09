# frozen_string_literal: true

module TaskPegion
  # Read task types and notification urls from config.yml
  class Config
    require 'yaml'

    attr_reader :task_types, :notification_urls

    def initialize
      @task_types = config_file['task_types']
      @notification_urls = config_file['notification_urls']
    end

    private

    def config_file
      if File.exist?('config.yml')
        YAML.load_file('config.yml')
      else
        { 'task_types' => %w[Main Sub Other] }
      end
    end
  end
end
