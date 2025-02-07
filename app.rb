# frozen_string_literal: true

require 'sinatra'
require 'json'
require_relative 'pre_processor'

class App < Sinatra::Base
  set :file, ENV['FILE'] || 'lisbon.txt'
  set :pre_processor, PreProcessor.new(settings.file)
  set :text_title, 'Poème sur le désastre de Lisbonne'

  get '/lines/:line_index' do
    line_index = params[:line_index].to_i

    begin
      line = settings.pre_processor.get_line(line_index)
      status 200
      content_type :json

      { title: settings.text_title, line: line }.to_json
    rescue IndexError
      status 413
      content_type :json

      { error: 'Line index out of range' }.to_json
    rescue StandardError => e
      status 500
      content_type :json

      { error: 'An error occurred', message: e.message }.to_json
    end
  end

  error 500 do
    content_type :json
    { error: 'An error occurred', message: env['sinatra.error'].message }.to_json
  end

  run! if app_file == $PROGRAM_NAME
end
