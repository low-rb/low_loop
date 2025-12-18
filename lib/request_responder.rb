# frozen_string_literal: true

module Low
  class RequestResponder
    class << self
      proc do
        ['200', { 'Content-Type' => 'text/html' }, ["Hello world! The time is #{Time.now}"]]
      end
    end
  end
end
