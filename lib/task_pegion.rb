# frozen_string_literal: true

require 'optionparser'

require_relative "task_pegion/version"
require_relative 'task_pegion/config'
require_relative 'task_pegion/record'
require_relative 'task_pegion/notifier'
require_relative 'task_pegion/cli'
require_relative 'task_pegion/pomodoro'

module TaskPegion
  class Error < StandardError; end
  # Your code goes here...

  class << self
    def main
      options = parse_options
      if options[:daily]
        puts 'Daily summary. Function is not implemented yet.'
      elsif options[:weekly]
        puts 'Weekly summary. Function is not implemented yet.'
      elsif options[:monthly]
        puts 'Monthly summary. Function is not implemented yet.'
      else
        Cli.new
      end
    end

    def parse_options
      options = {}
      opts = OptionParser.new do |opt|
        opt.on_head('-ds', 'Daily summary') { options[:daily] = true }
        opt.on_head('-ws', 'Weekly summary') { options[:weekly] = true }
        opt.on_head('-ms', 'Monthly summary') { options[:monthly] = true }
      end

      opts.parse!(ARGV, into: options)
      options
    end
  end
end

TaskPegion.main if $0 == __FILE__
