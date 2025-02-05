# frozen_string_literal: true

require 'spec_helper'
require 'puma'

RSpec.describe 'Line Server API' do # rubocop:disable Metrics/BlockLength
  subject(:do_action) { get "/lines/#{line_index}" }

  let(:line_index) { 0 }

  before { allow_any_instance_of(PreProcessor).to receive(:get_line).and_call_original }

  describe 'GET /lines/:line_index' do
    it 'exists and returns status 200' do
      do_action
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      expect(response).to include('title', 'line')
      expect(response['line']).to be_a(String)
      expect(response['title']).to eq('Poème sur le désastre de Lisbonne')
    end
  end

  describe 'it calls the pre_processor with the correct params' do
    it 'calls the pre_processor with the correct line index' do
      do_action
      expect(app.settings.pre_processor).to have_received(:get_line).with(line_index)
    end
  end

  describe 'error handling' do
    context 'when the line index is out of range' do
      let(:line_index) { 999 }

      it 'returns status 413' do
        do_action
        expect(last_response.status).to eq(413)

        response = JSON.parse(last_response.body)
        expect(response).to include('error')
        expect(response['error']).to eq('Line index out of range')
      end
    end
  end

  describe 'Stress test API with Puma' do
    let(:line_index) { 0 }
    let(:server) { Puma::Server.new(app) }
    
    it 'handles concurrent requests' do
      server.add_tcp_listener '127.0.0.1', 9292
      server.run

      threads = []
      10.times do
        threads << Thread.new do
          do_action
          expect(last_response.status).to eq(200)
        end
      end

      threads.each(&:join)
      server.stop(true)
    end
  end
end
