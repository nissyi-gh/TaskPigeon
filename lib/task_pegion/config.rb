# frozen_string_literal: true

class TaskPegion::Config
  attr_reader :task_types

  def initialize
    @task_types = config_file['task_types']
  end

  private

  def config_file
    YAML.load_file('config.yml')
  end
end
