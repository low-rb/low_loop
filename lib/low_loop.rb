# frozen_string_literal: true

require 'async'
require 'socket'
require 'low_type'
require 'low_event'
require 'observers'

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
            sleep config.sleep_duration if config.sleep_duration > 0

            request = RequestParser.parse(socket:, host: config.host, port: config.port)

            # NEXT:
            #  Have a RainRouter in between LowLoop and the LowNodes that are subscribed to routes for the RainRouter.

            response_event = LowLoop.take RequestEvent.new(request:)

            ResponseBuilder.respond(config:, socket:, response: response_event.response)
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
