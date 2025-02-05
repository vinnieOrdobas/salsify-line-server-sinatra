# frozen_string_literal: true

class PreProcessor
  attr_reader :file_path, :offsets, :text

  def initialize(file_path)
    @offsets = []
    @text = File.read(file_path)
    process_file
  end

  def process_file
    offset = 0
    @text.each_line do |line|
      @offsets << offset
      offset += line.bytesize
    end
  end

  def get_line(index)
    raise IndexError, 'Line index out of range' if index_out_of_range?(index)

    @text.each_line.with_index do |line, i|
      return line if i == index
    end
  end

  def index_out_of_range?(index)
    index.negative? || index >= @offsets.size
  end
end
