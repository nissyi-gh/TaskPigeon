# frozen_string_literal: true

module TaskPegion
  # Read task types and notification urls from config.yml
  class Config
    require 'yaml'

    attr_reader :task_types, :destinations

    def initialize
      @task_types = config_file['task_types']
      @destinations = config_file['destinations']
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
