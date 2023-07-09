# frozen_string_literal: true

module TaskPegion
  class Record
    require 'csv'

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

    def elapsed_time_formatted
      "#{elapsed_time[:hours]}時間#{elapsed_time[:minutes]}分#{elapsed_time[:seconds]}秒"
    end

    private

    def new_id
      CSV.read('records.csv').size
    end

    def elapsed_time
      elapse_seconds = (Time.new(ended_at) - Time.new(started_at)).round
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
  end
end
