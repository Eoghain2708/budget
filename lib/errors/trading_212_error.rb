module Budget
  module Errors
    class Trading212 < StandardError
      def initialize(message="Error fetching data")
        super(message)
      end
    end
  end
end