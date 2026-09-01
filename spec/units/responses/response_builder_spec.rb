# frozen_string_literal: true

require 'stringio'
require 'protocol/http'

require_relative '../../../lib/support/config_loader'
require_relative '../../../lib/responses/response_builder'

RSpec.describe Low::ResponseBuilder do
  subject(:respond) do
    described_class.respond(config:, socket:, response:, keep_alive: true)
  end

  let(:config) { Low::ConfigLoader.load('./spec/fixtures/config.yaml') }
  let(:socket) { StringIO.new }
  let(:output) { socket.string }

  def response_with(headers_pairs, body: 'Hi')
    headers = Protocol::HTTP::Headers.new
    headers_pairs.each { |key, value| headers.add(key, value) }
    Protocol::HTTP::Response.new('HTTP/1.1', 200, headers, Protocol::HTTP::Body::Buffered.wrap(body))
  end

  context 'with a single response header' do
    let(:response) { response_with([['content-type', 'text/html']]) }

    it 'writes a well-formed Content-Type header line' do
      respond
      expect(output).to include("content-type: text/html\r\n")
    end

    it 'does not write the header name as a stringified array' do
      respond
      expect(output).not_to include('["content-type"')
    end
  end

  context 'with multiple response headers' do
    let(:response) do
      response_with([['content-type', 'text/html'], ['cache-control', 'no-cache']])
    end

    it 'writes each header on its own well-formed line' do
      respond
      expect(output).to include("content-type: text/html\r\n")
      expect(output).to include("cache-control: no-cache\r\n")
    end
  end

  context 'with a buffered body' do
    let(:response) { response_with([['content-type', 'text/html']], body: 'Hi') }

    it 'writes the status line, headers, and body in a single socket write' do
      allow(socket).to receive(:write).and_call_original

      respond

      expect(socket).to have_received(:write).exactly(1).time
    end

    it 'still writes a well-formed response' do
      respond
      expect(output).to start_with("HTTP/1.1 200\r\n")
      expect(output).to end_with("\r\n\r\nHi")
    end
  end
end
