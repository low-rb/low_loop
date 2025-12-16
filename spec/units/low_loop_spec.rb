# frozen_string_literal: true

require 'protocol/http'
require 'low_event'

require_relative '../../lib/low_loop'
require_relative '../fixtures/rain_router'

RSpec.describe LowLoop do
  subject(:low_loop) { described_class.new }

  let(:request_event) { Low::RequestEvent.new(request:, action: :response) }
  # TODO: Convert to FactoryBot.
  let(:request) do
    Protocol::HTTP::Request.new('http', "#{ENV['HOST']}:#{ENV['PORT']}", 'GET', '/front', 'http/1.1', Protocol::HTTP::Headers[["accept", "text/html"]])
  end
  let(:response_event) { Low::ResponseEvent.new }
  
  before do
    stub_const('ENV', ENV.to_h.merge('PORT' => 4133, 'HOST' => '127.0.0.1'))
    allow(RainRouter).to receive(:response).with(event: request_event).and_return(response_event)
  end

  describe '#initialize' do
    it 'instantiates a class' do
      expect { low_loop }.not_to raise_error
    end
  end

  context 'without an event loop' do
    it 'returns a response' do
      expect(LowLoop.take request_event).to be_instance_of(Low::ResponseEvent)
    end
  end

  # context 'with an event loop' do
  #   before(:all) do
  #     @server = Thread.new do
  #       low_loop.start
  #     end
  #     sleep 0.1
  #   end

  #   after(:all) do
  #     @server.kill
  #   end
  # end
end
