# frozen_string_literal: true

require 'sinatra'
require 'json'
require './pre_processor'

class App < Sinatra::Base
  def initialize(pre_processor: PreProcessor.new('lisbon.txt'))
    super()
    @pre_processor = pre_processor
    @text_tile = 'Poème sur le désastre de Lisbonne'
  end

  # GET /lines/:line_index
  get '/lines/:line_index' do
    line_index = params[:line_index].to_i

    begin
      line = @pre_processor.get_line(line_index)
      status 200
      content_type :json

      { title: @text_tile, line: line }.to_json
    rescue IndexError
      status 413
      content_type :json

      { error: 'Line index out of range' }.to_json
    end
  end
end
