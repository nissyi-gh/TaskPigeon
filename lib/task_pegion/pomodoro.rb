# frozen_string_literal: true

module TaskPegion
  # Pomodoro Timer Class
  class Pomodoro
    # 25 minutes
    WORK_TIME = 1500
    # 5 minutes
    BREAK_TIME = 300

    attr_reader :config
    attr_accessor :intterupted

    def initialize
      @config = Config.new
      @interrupted = false

      timer_and_notice
    end

    private

    def timer_and_notice
      Signal.trap(:INT) { @interrupted = true }

      loop do
        sleep 0.5

        if @interrupted
          if Cli::StopPrompter.new.stop
            exit
          else
            @interrupted = false
          end
        end

        @config.destinations.each do |destination|
          if destination['notice_types'].include?('pomodoro')
            Notifier.new(destination['url'], { text: 'タスク開始から25分経過しました。一息つきませんか？' }).notice
          end
        end

        @config.destinations.each do |destination|
          if destination['notice_types'].include?('pomodoro')
            Notifier.new(destination['url'], { text: '5分経過しました。タスクに戻りましょう!' }).notice
          end
        end
      end
    end
  end
end
