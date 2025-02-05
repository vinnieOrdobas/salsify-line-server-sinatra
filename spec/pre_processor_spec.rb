# frozen_string_literal: true

require './pre_processor'

RSpec.describe PreProcessor do
  let(:file_path) { File.expand_path('mocked_text.txt', __dir__) }
  let(:pre_processor) { PreProcessor.new(file_path) }
  let(:lines) { pre_processor.text.lines }
  let(:expected_result) { [0, lines[0].bytesize, lines[0].bytesize + lines[1].bytesize] }

  before do
    allow(File).to receive(:read).and_call_original
  end

  describe '#initialize' do
    it 'creates an offset array based on line starts' do
      expect(pre_processor.offsets).to eq(expected_result)
    end
  end

  describe '#get_line' do
    it 'retrieves the correct line based on index' do
      expect(pre_processor.get_line(0)).to eq("First Line.\n")
      expect(pre_processor.get_line(1)).to eq("Second Line.\n")
      expect(pre_processor.get_line(2)).to eq('Third Line.')
    end

    it 'raises an IndexError for out-of-range indices' do
      expect { pre_processor.get_line(3) }.to raise_error(IndexError, 'Line index out of range')
      expect { pre_processor.get_line(-1) }.to raise_error(IndexError, 'Line index out of range')
    end
  end
end
