# frozen_string_literal: true

module TaskPegion
  # Read task types and notification urls from config.yml
  class Config
    require 'yaml'

    attr_reader :user_name, :task_types, :destinations

    def initialize
      @user_name = config_file['user_name']
      @task_types = task_converter(config_file['task_types'])
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

    def task_converter(task_types)
      task_types.map do |task_type|
        if task_type['short'] && task_type['long']
          [task_type['short'], task_type['long']]
        # short only, or long only is invalid
        elsif task_type.is_a?(Hash)
          puts "#{task_type} is invalid. if you want to set the short and long, please set both."
        else
          [task_type, task_type]
        end
      end.to_h
    end
  end
end
