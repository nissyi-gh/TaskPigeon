# frozen_string_literal: true

module TaskPegion
  require 'time'

  # Pomodoro Timer Class
  class Pomodoro
    # 25 minutes
    WORK_TIME = 1500
    # 5 minutes
    BREAK_TIME = 300

    attr_reader :config, :started_at
    attr_accessor :interrupted, :elapsed_time, :next_notice_time, :next_notice_type

    def initialize
      @config = Config.new
      @started_at = Time.now
      @interrupted = false
      @elapsed_time = 0
      @next_notice_time = WORK_TIME
      @next_notice_type = 'break'
    end

    def run
      Signal.trap(:INT) { @interrupted = true }

      loop do
        sleep 0.5
        update_elapsed_time
        hundle_interrupt
        send_break_notice if break_time?
        send_work_notice if work_time?
      end
    end

    private

    def update_elapsed_time
      @elapsed_time = Time.now - @started_at
    end

    def hundle_interrupt
      if @interrupted
        if Cli::StopPrompter.new.stop
          exit
        else
          @interrupted = false
        end
      end
    end

    def send_break_notice
      @next_notice_time += BREAK_TIME
      @next_notice_type = 'work'
      text = "#{@config.user_name} タスク開始から25分経過しました。一息つきませんか？"

      Notifier.new('pomodoro', text).notice
    end

    def send_work_notice
      @next_notice_time += WORK_TIME
      @next_notice_type = 'break'
      text = "#{@config.user_name} そろそろ休憩終わり！タスクに戻りましょう！"

      Notifier.new('pomodoro', text).notice
    end

    def break_time?
      @elapsed_time >= @next_notice_time && @next_notice_type == 'break'
    end

    def work_time?
      @elapsed_time >= @next_notice_time && @next_notice_type == 'work'
    end
  end
end
