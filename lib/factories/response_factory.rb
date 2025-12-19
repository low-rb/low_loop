# frozen_string_literal: true

require 'protocol/http'

module Low
  class ResponseFactory
    class << self
      def response(body:)
        headers = Protocol::HTTP::Headers.new(['content-type', 'text/html'])
        body = Protocol::HTTP::Body::Buffered.wrap(body)

        Protocol::HTTP::Response.new('http/1.1', 200, headers, body)
      end
    end
  end
end
