# frozen_string_literal: true

module TaskPegion
  # Provide functions when run from command line
  class Cli
    def initialize
      if Record.last.ended_at.nil?
        # TODO: StopPrompter.new
      else
        StartPrompter.new
      end
    end

    # Interact with user to start task
    class StartPrompter
      attr_reader :config

      def initialize
        @config = TaskPegion::Config.new

        prompter
      end

      def prompter
        task_type = prompt_task_type
        task_name = prompt_task_name

        record = Record.new(task_type: task_type, task_name: task_name)
        record.save

        @config.destinations.each do |destination|
          if destination['notice_types'].include?('start')
            Notifier.new(destination['url'], { text: "#{config.user_name}が#{task_type}の#{task_name}を開始しました。" }).notice
          end
        end
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
