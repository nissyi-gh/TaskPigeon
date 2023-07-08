# frozen_string_literal: true

module TaskPegion
  # Define the configuration class
  class Config
    require 'yaml'

    attr_reader :task_types

    def initialize
      @task_types = config_file['task_types']
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
