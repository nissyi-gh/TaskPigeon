# frozen_string_literal: true

module TaskPegion
  # Provide functions when run from command line
  class Cli
    class StartPrompter
      attr_reader :config

      def initialize
        @config = TaskPegion::Config.new

        prompter
      end

      def prompter
        task_type = prompt_task_type
        task_name = prompt_task_name
        puts "task_type: #{task_type}, task_name: #{task_name}"
      end

      private

      def prompt_task_type
        show_task_types
        puts 'Please select task type from above'

        loop do
          task_type = gets.chomp
          return task_type if config.task_types.include?(task_type)

          puts 'Please input valid task type'
        end
      end

      def show_task_types
        puts 'Your task types:'
        config.task_types.each_slice(3) do |task_types|
          puts task_types.join(' ')
        end
        puts ''
      end

      def prompt_task_name
        loop do
          puts 'Please input task name'
          task_name = gets.chomp
          return task_name unless task_name.empty?
        end
      end
    end
  end
end
