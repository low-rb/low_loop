# frozen_string_literal: true

require 'benchmark'

require 'net/http'
require 'uri'
require 'async'
require 'async/http/internet'
require 'protocol/http'
require 'socket'

require 'low_event'
require_relative '../../lib/factories/request_factory'
require_relative '../../lib/factories/response_factory'
require_relative '../../lib/low_loop'
require_relative '../fixtures/rain_router'

RSpec.describe LowLoop do
  subject(:low_loop) { described_class.new }

  let(:request_event) { Low::RequestEvent.new(request:) }
  let(:request) { Low::RequestFactory.request(path: '/') }

  let(:response_event) { Low::ResponseEvent.new(response:) }
  let(:response) { Low::ResponseFactory.response(body:) }
  let(:body) { 'Hello' }

  let(:host) { "http://#{ENV['HOST']}:#{ENV['PORT']}" }
  let(:client) { Async::HTTP::Internet.new }
  # Or could be more direct:
  # endpoint = Async::HTTP::Endpoint["http://#{ENV['HOST']}:#{ENV['PORT']}"]
  # client = Async::HTTP::Client.new(endpoint)

  before do
    stub_const('ENV', ENV.to_h.merge('HOST' => '127.0.0.1', 'PORT' => 4133))
    allow(RainRouter).to receive(:handle_event).and_return(response_event)
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
      @server = Thread.new do
        described_class.new.start
      end
      sleep 0.1
    end

    it 'responds to a request' do
      expect(Net::HTTP.get_response(URI.parse(host)).body.strip).to eq(body)
    end

    # it 'responds to requests asynchronously' do
    #   duration = Benchmark.measure do
    #     Async do
    #       tasks = urls.map do |url|
    #       Async do
    #         response = client.get("http://#{ENV['HOST']}:#{ENV['PORT']}/front")
    #         body = response.read
    #         response.close
    #       end
    #       results = tasks.map(&:result)
    #     end
    #   end.real
    # end

    after(:all) do
      @server.kill
    end
  end
end
