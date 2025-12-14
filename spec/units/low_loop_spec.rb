# frozen_string_literal: true

require 'protocol/http'
require_relative '../../lib/low_loop'

RSpec.describe LowLoop do
  subject(:low_loop) { described_class.new }

  before do
    stub_const('ENV', ENV.to_h.merge('PORT' => 4133, 'HOST' => '127.0.0.1'))
  end

  describe '#initialize' do
    it 'instantiates a class' do
      expect { low_loop }.not_to raise_error
    end
  end

  context 'without an event loop' do
    let(:event) { Low::RequestEvent.new(request:) }
    # TODO: Convert to FactoryBot.
    let(:request) do
      Protocol::HTTP::Request.new('http', "#{ENV['HOST']}:#{ENV['PORT']}", 'GET', '/front', 'http/1.1', Protocol::HTTP::Headers[["accept", "text/html"]])
    end

    it 'returns a response' do
      expect(LowLoop.take Low::RequestEvent.new(request:).class).to eq(Low::ResponseEvent)
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
