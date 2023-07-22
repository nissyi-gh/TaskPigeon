# frozen_string_literal: true

module TaskPegion
  # Provide functions when run from command line
  class Cli
    def initialize
      if Record.last.ended_at.nil?
        StopPrompter.new
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
        use_pomodoro = prompt_pomodoro

        record = Record.new(task_type: task_type, task_name: task_name)
        record.save

        @config.destinations.each do |destination|
          if destination['notice_types'].include?('start')
            Notifier.new(destination['url'], { text: "#{config.user_name}が#{task_type}の#{task_name}を開始しました。" }).notice
          end
        end

        if use_pomodoro
          puts 'Pomodoro timer is started. Press Ctrl+C to stop.'
          Pomodoro.new
        else
          puts 'Task is started. Execute task_pegion to end task.'
        end
      end

      private

      def prompt_task_type
        show_task_types
        puts 'Please select task type from above'

        loop do
          task_type = gets.chomp
          config.task_types.each do |k, v|
            if task_type == k
              puts "You selected '#{v}'"
              return v
            end
          end

          puts 'Please input valid task type'
        end
      end

      def show_task_types
        puts 'Your task types:'
        config.task_types.each do |k, v|
          puts k == v ? k : "#{k}: #{v}"
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

      def prompt_pomodoro
        puts 'Do you want to use pomodoro timer? (y/n)'
        answer = gets.chomp

        answer == 'y'
      end
    end

    # Interact with user to stop task
    class StopPrompter
      def initialize
        @config = TaskPegion::Config.new
        @record = Record.last

        prompter
      end

      def prompter
        puts "You are working on #{@record.task_type} #{@record.task_name}"
        puts 'Are you sure to stop this task? (y/n)'
        answer = gets.chomp

        if answer == 'y'
          @record.ended_at = Time.now.to_s

          csv_data = CSV.read('records.csv')
          csv_data[-1][4] = @record.ended_at

          CSV.open('records.csv', 'w') do |csv|
            csv_data.each do |row|
              csv << row
            end
          end

          @config.destinations.each do |destination|
            if destination['notice_types'].include?('end')
              text = <<~TEXT
                #{@config.user_name}が#{@record.task_type}の#{@record.task_name}を終了しました。
                経過時間は#{@record.elapsed_time_formatted}です。

                サマリ
                #{Record.summary.drop(1).join("\n")}
              TEXT
              Notifier.new(destination['url'], { text: text }).notice
            end
          end
        else
          puts 'Task is not stopped'
          return false
        end
      end
    end
  end
end
