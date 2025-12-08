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

        request = parse_request(stream:)
        require 'pry'; binding.pry

        # headers = parse_headers(stream:)

        # ::Protocol::HTTP::Request.new(scheme = nil, authority = nil, method = nil, path = nil, version = nil, headers = Headers.new, body = nil, protocol = nil)
      end

      private

      # TODO: Handle namespaced stream type "IO:Stream".
      def parse_request(stream:)
        request_line = stream.gets

        raise StandardError, "EOF" unless request_line

        method, full_path, * = request_line.strip.split(' ', 2)
        path, query = full_path.split('?', 2)

        [method, full_path, path, query]
      end

      # TODO: Handle namespaced stream type "IO:Stream".
      def parse_headers(stream:) -> { ::Protocol::HTTP::Headers }
        ::Protocol::HTTP::Headers.new([['key', 'value']])
      end
    end
  end
end
