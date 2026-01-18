module ConfigSupport
  class << self
    def parse_boolean(value)
      value == '1' ? true : value == '0' ? false : nil
    end
  end
end
