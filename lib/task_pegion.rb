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
    if options[:start] && options[:end]
      raise Error, 'Cannot specify both --start and --end'
    elsif options[:start]
      task_start(options[:task_type], options[:task_name])
    elsif options[:end]
      task_end(options[:task_type], options[:task_name])
    else
      raise Error, 'Specify --start or --end'
    end
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

  def self.task_start(task_type, task_name)
    if Record.last&.ended_at.nil?
      raise Error, 'Task is already started'
    end

    record = Record.new(task_type: task_type, task_name: task_name)
    record.save

    Config.new.destinations.each do |destination|
      if destination['notice_types'].include?('start')
        Notifier.new(destination['url'], { text: "Start #{task_type}: #{task_name} at #{record.started_at}" }).notice
      end
    end
  end

  def self.task_end(task_type, task_name)
    record = Record.last

    if record.task_type != task_type || record.task_name != task_name
      raise Error, "Task type or task name is not matched. Task type: #{task_type}, Task name: #{task_name}"
    elsif record.ended_at
      raise Error, 'Task is already ended'
    else
      record.ended_at = Time.now

      csv_data = CSV.read('records.csv')
      csv_data[-1][4] = record.ended_at

      CSV.open('records.csv', 'w') do |csv|
        csv_data.each do |row|
          csv << row
        end
      end

      Config.new.destinations.each do |destination|
        if destination['notice_types'].include?('end')
          Notifier.new(destination['url'], { text: "End #{task_type}: #{task_name} at #{record.started_at}" }).notice
        end
      end
    end
  end
end

TaskPegion.main
