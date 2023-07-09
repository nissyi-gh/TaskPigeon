# frozen_string_literal: true

require 'optionparser'

require_relative "task_pegion/version"
require_relative 'task_pegion/config'
require_relative 'task_pegion/record'
require_relative 'task_pegion/notifier'

module TaskPegion
  class Error < StandardError; end
  # Your code goes here...

  def self.main
    options = parse_options
  end

  def self.parse_options
    options = {}
    opt = OptionParser.new do |opt|
      opt.on_head('-s', '--start', 'Start task') { options[:start] = true }
      opt.on_head('-e', '--end', 'End task') { options[:end] = true }
      opt.on('-t TYPE', '--task-type TYPE', 'Task type') { |v| options[:task_type] = v }
      opt.on('-n NAME', '--task-name NAME', 'Task name') { |v| options[:task_name] = v }
    end

    opt.parse!(ARGV, into: options)
    options
  end
end

TaskPegion.main
