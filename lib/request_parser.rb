# frozen_string_literal: true

require 'io/stream'
require 'async/http'
require 'protocol/http'

module Low
  class RequestParser
    include LowType

    class << self
      def parse(socket: TCPSocket)
        stream = IO::Stream(socket)
        protocol = Async::HTTP::Protocol::HTTP.default.protocol_for(stream)

        method, full_path, path, query = parse_request(stream:)
        headers = parse_headers(stream:)

        require 'pry'; require 'pry-nav'; binding.pry

        # ::Protocol::HTTP::Request.new(scheme = nil, authority = nil, method = nil, path = nil, version = nil, headers = Headers.new, body = nil, protocol = nil)
      end

      private

      # TODO: Handle namespaced stream type "IO:Stream".
      def parse_request(stream:)
        request_line = stream.gets || raise(StandardError, 'EOF')
        
        method, full_path, _http_version = request_line.strip.split(' ', 3)
        path, query = full_path.split('?', 2)
        
        [method, full_path, path, query]
      end
      
      # TODO: Handle namespaced stream type "IO:Stream".
      def parse_headers(stream:) -> { ::Protocol::HTTP::Headers }
        fields = []

        while (line = stream.gets.strip) do
          break if line.strip.empty?

          key, value = line.split(/:\s/, 2)
          fields << [key, value]
        end

        ::Protocol::HTTP::Headers.new(fields)
      end
    end
  end
end
