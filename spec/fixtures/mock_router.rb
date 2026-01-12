# frozen_string_literal: true

require 'observers'
require_relative '../../lib/low_loop'

class MockRouter
  include Observers

  def initialize(low_loop:)
    observe low_loop
  end

  def handle(event:)
    # Return value is stubbed.
  end
end
