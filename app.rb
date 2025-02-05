# frozen_string_literal: true

require 'sinatra'
require 'json'
require_relative 'pre_processor'

class App < Sinatra::Base
  set :pre_processor, PreProcessor.new('lisbon.txt')
  set :text_tile, 'Poème sur le désastre de Lisbonne'

  get '/lines/:line_index' do
    line_index = params[:line_index].to_i

    begin
      line = settings.pre_processor.get_line(line_index)
      status 200
      content_type :json

      { title: settings.text_tile, line: line }.to_json
    rescue IndexError
      status 413
      content_type :json

      { error: 'Line index out of range' }.to_json
    end
  end

  run! if app_file == $PROGRAM_NAME
end