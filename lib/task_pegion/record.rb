# frozen_string_literal: true

module TaskPegion
  class Record
    require 'csv'
    require 'time'

    attr_reader :id
    attr_accessor :task_type, :task_name, :started_at, :ended_at

    def initialize(id: new_id, task_type: 'Other', task_name: nil, started_at: Time.now, ended_at: nil)
      @id = id
      @task_type = task_type
      @task_name = task_name
      @started_at = started_at
      @ended_at = ended_at
    end

    def save
      CSV.open('records.csv', 'a') do |csv|
        csv << [id, task_type, task_name, started_at, ended_at]
      end
    end

    def self.last
      row = CSV.read('records.csv').last
      new(id: row[0], task_type: row[1], task_name: row[2], started_at: row[3], ended_at: row[4])
    end

    def self.summary
      beginning_of_today = Time.new(Time.new.strftime('%Y-%m-%d'))
      end_of_today = Time.new(Time.new.strftime('%Y-%m-%d 23:59:59'))
      today_records = []

      CSV.foreach('records.csv', headers: true).map do |row|
        if Time.new(row[3]) >= beginning_of_today && Time.new(row[3]) <= end_of_today
          today_records << new(id: row[0], task_type: row[1], task_name: row[2], started_at: row[3], ended_at: row[4])
        end
      end

      summary = { total: 0 }
      today_records.each do |record|
        summary[record.task_type] = 0 if summary[record.task_type].nil?

        summary[record.task_type] += record.elapsed_time[:total]
        summary[:total] += record.elapsed_time[:total]
      end

      summary.map do |task_type, total|
        hours = total / 3600
        minutes = (total % 3600) / 60
        seconds = total % 60

        "#{task_type}: #{hours}時間#{minutes}分#{seconds}秒 (#{(total.to_f / summary[:total] * 100).round(1)}%)"
      end
    end

    def elapsed_time_formatted
      "#{elapsed_time[:hours]}時間#{elapsed_time[:minutes]}分#{elapsed_time[:seconds]}秒"
    end

    def elapsed_time
      elapse_seconds = (Time.parse(ended_at) - Time.parse(started_at)).round
      hours = elapse_seconds / 3600
      minutes = (elapse_seconds % 3600) / 60
      seconds = elapse_seconds % 60

      {
        total: elapse_seconds,
        hours: hours,
        minutes: minutes,
        seconds: seconds
      }
    end

    private

    def new_id
      CSV.read('records.csv').size
    end
  end
end
