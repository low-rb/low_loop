# frozen_string_literal: true

require 'async'
require 'socket'
require 'low_type'
require 'low_event'
require 'observers'

require_relative 'factories/response_factory'
require_relative 'request_parser'
require_relative 'response_builder'

module Low
  class Loop
    include Observers

    def start(config:)
      server = TCPServer.new(config.host, config.port)
      server.listen(10)
      puts "Server@#{config.host}:#{config.port}" if config.matrix_mode

      Fiber.set_scheduler(Async::Scheduler.new)

      Fiber.schedule do
        loop do
          socket = server.accept

          Fiber.schedule do
            request = RequestParser.parse(socket:, host: config.host, port: config.port)

            if config.mirror_mode
              response = ResponseFactory.response(body: "Thank you for visiting #{request.path} with '#{request.body}'")
            else
              response_event = take(Events::RequestEvent.new(request:))
              response = response_event.response
            end

            ResponseBuilder.respond(config:, socket:, response:)
          rescue StandardError => e
            puts e.message
          ensure
            socket&.close
          end
        end
      end
    end

    # Consider LowLoop a value object in the context of Observers (there can only be one).
    def ==(other) = other.class == self.class
    def eql?(other) = self == other
    def hash = [self.class].hash
  end
end

LowLoop = Low::Loop
