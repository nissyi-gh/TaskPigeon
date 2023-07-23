# frozen_string_literal: true

RSpec.describe TaskPegion::Pomodoro do
  let(:started_at) { Time.now }
  let(:pomodoro) do
    started_at
    TaskPegion::Pomodoro.new
  end

  describe '#initialize' do
    it 'initialize Config' do
      expect(TaskPegion::Config).to receive(:new)
      pomodoro
    end

    it 'sets default values' do
      expect(pomodoro.started_at).to be_within(1).of(started_at)
      expect(pomodoro.interrupted).to eq(false)
      expect(pomodoro.elapsed_time).to eq(0)
      expect(pomodoro.next_notice_time).to eq(TaskPegion::Pomodoro::WORK_TIME)
      expect(pomodoro.next_notice_type).to eq('break')
    end
  end

  # TODO: write test for #run, #update_elapsed_time, #hundle_interrupt, #send_break_notice, #send_work_notice
end
