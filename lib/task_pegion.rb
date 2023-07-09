# frozen_string_literal: true

require 'optionparser'

require_relative "task_pegion/version"
require_relative 'task_pegion/config'
require_relative 'task_pegion/record'
require_relative 'task_pegion/notifier'

module TaskPegion
  class Error < StandardError; end
  # Your code goes here...

  class << self
    def main
      options = parse_options
      if options[:start] && options[:end]
        raise Error, 'Cannot specify both --start and --end'
      elsif options[:start]
        task_start(options[:task_type], options[:task_name])
      elsif options[:end]
        task_end
      else
        raise Error, 'Specify --start or --end'
      end
    end

    def parse_options
      options = {}
      opt = OptionParser.new do |opt|
        opt.on_head('-s', '--start', 'Start task') { options[:start] = true }
        opt.on_head('-e', '--end', 'End task') { options[:end] = true }
        opt.on('-t [TYPE]', '--task-type [TYPE]', 'Task type') { |v| options[:task_type] = v }
        opt.on('-n [NAME]', '--task-name [NAME]', 'Task name') { |v| options[:task_name] = v }
      end

      opt.parse!(ARGV, into: options)
      options
    end

    def task_start(task_type, task_name)
      if Record.last&.ended_at.nil?
        raise Error, 'Task is already started'
      elsif task_type.nil? || task_name.nil?
        raise Error, 'Specify task type and task name'
      end

      record = Record.new(task_type: task_type, task_name: task_name)
      record.save

      config = Config.new
      config.destinations.each do |destination|
        if destination['notice_types'].include?('start')
          Notifier.new(destination['url'], { text: "#{config.user_name}が#{task_type}の#{task_name}を開始しました。" }).notice
        end
      end
    end

    def task_end
      record = Record.last

      if record.ended_at
        raise Error, 'Task is already ended'
      else
        record.ended_at = Time.now.to_s

        csv_data = CSV.read('records.csv')
        csv_data[-1][4] = record.ended_at

        CSV.open('records.csv', 'w') do |csv|
          csv_data.each do |row|
            csv << row
          end
        end

        config = Config.new
        config.destinations.each do |destination|
          if destination['notice_types'].include?('end')
            text = <<~TEXT
              #{config.user_name}が#{record.task_type}の#{record.task_name}を終了しました。
              経過時間は#{record.elapsed_time_formatted}です。
            TEXT
            Notifier.new(destination['url'], { text: text }).notice
          end
        end
      end
    end
  end
end

TaskPegion.main if $0 == __FILE__
