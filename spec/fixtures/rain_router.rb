# frozen_string_literal: true

require 'observers'
require_relative '../../lib/low_loop'

class RainRouter
  extend Observers
  observe LowLoop

  class << self
    def handle_event(event:)
      # Return value is stubbed.
    end
  end
end
