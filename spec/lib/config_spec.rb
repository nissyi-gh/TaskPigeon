# frozen_string_literal: true

RSpec.describe TaskPegion::Config do
  let(:default_config) { { 'task_types' => %w[Main Sub Other] } }

  context 'when config.yml does not exist' do
    before do
      allow(File).to receive(:exist?).and_return(false)
    end

    it 'returns default task_types' do
      expect(subject.task_types).to eq(default_config['task_types'])
    end
  end

  context 'when config.yml exists' do
    let(:default_config) { { 'task_types' => %w[Main Sub Other] } }
    let(:config) { TaskPegion::Config.new }

    before { allow(YAML).to receive(:load_file).and_return(default_config) }

    it 'returns task_types from config.yml' do
      expect(config.task_types).to eq(default_config['task_types'])
    end
  end
end
