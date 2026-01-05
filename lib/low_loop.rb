# frozen_string_literal: true

require 'async'
require 'socket'
require 'low_type'
require 'low_event' # TODO: Move RequestEvent and ResponseEvent into this gem.
require 'observers'

require_relative 'factories/response_factory'
require_relative 'request_parser'
require_relative 'response_builder'

module Low
  class Loop
    extend Observers
    observable

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
              response = Low::ResponseFactory.response(body: "Thank you for visiting #{request.path} with '#{request.body}'")
            else
              response_event = LowLoop.take RequestEvent.new(request:)
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
  end
end

LowLoop = Low::Loop
