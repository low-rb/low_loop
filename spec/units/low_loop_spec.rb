# frozen_string_literal: true

require 'benchmark'

require 'net/http'
require 'uri'
require 'async'
require 'async/http/internet'
require 'protocol/http'
require 'socket'

require 'low_event'
require_relative '../../lib/factories/response_factory'
require_relative '../../lib/low_loop'
require_relative '../factories/request_factory'
require_relative '../fixtures/mock_router'

RSpec.describe LowLoop do
  subject(:low_loop) { described_class.new }

  let(:request_event) { Low::Events::RequestEvent.new(request:) }
  let(:request) { Low::RequestFactory.request(path: '/') }

  def response_event(response:, delay_duration: 0)
    sleep delay_duration if delay_duration > 0
    Low::Events::ResponseEvent.new(response:)
  end
  let(:response) { Low::Events::ResponseFactory.response(body:) }
  let(:body) { 'Hello' }

  let(:endpoint) { "http://#{host}:#{port}" }
  let(:host) { '127.0.0.1' }
  let(:port) { 4133 }
  let(:client) { Async::HTTP::Internet.new }
  # Or could be more direct:
  # endpoint = Async::HTTP::Endpoint["http://#{host}:#{port}"]
  # client = Async::HTTP::Client.new(endpoint)

  before do
    allow(mock_router).to receive(:handle).and_return(response_event(response:))
  end

  describe '#initialize' do
    it 'instantiates a class' do
      expect { low_loop }.not_to raise_error
    end
  end

  context 'without an event loop' do
    it 'responds to a request' do
      expect(LowLoop.take(request_event)).to be_instance_of(Low::ResponseEvent)
    end
  end

  context 'with an event loop' do
    before(:all) do
      config = Struct.new(:host, :port, :matrix_mode)
      @server = Thread.new do
        described_class.new.start(config: config.new('127.0.0.1', 4133, false))
      end
      sleep 0.1
    end

    before do
      # Delay response to mimic IO.
      allow(mock_router).to receive(:handle) do
        response_event(response:, delay_duration: 1)
      end
    end

    it 'responds to a request' do
      expect(Net::HTTP.get_response(URI.parse(endpoint)).body.strip).to eq(body)
    end

    context 'with blocking IO' do
      let(:request_count) { 100 }

      it 'responds to requests asynchronously' do
        duration = Benchmark.measure do
          Async do
            tasks = Array.new(request_count).map do
              Async do
                response = client.get(endpoint)
                body = response.read
                response.close
              end
            end

            results = tasks.map(&:result)
          end
        end.real

        expect(mock_router).to have_received(:handle).exactly(request_count).times
        expect(duration).to be < 1.1
      end
    end

    after(:all) do
      @server.kill
    end
  end
end
