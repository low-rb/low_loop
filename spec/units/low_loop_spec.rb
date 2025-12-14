# frozen_string_literal: true

require_relative '../../lib/low_loop'

RSpec.describe LowLoop do
  subject(:low_loop) { described_class.new }

  describe '#initialize' do
    it 'instantiates a class' do
      expect { low_loop }.not_to raise_error
    end
  end
end
