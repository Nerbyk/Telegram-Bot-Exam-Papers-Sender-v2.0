# frozen_string_literal: true

module replaced
  class A
    def self.get_a
      p TEST
    end
  end

  TEST = 'teest'
end

replaced::A.get_a

replaced::TEST = 10
p replaced::TEST
