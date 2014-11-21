require 'util/chained_error'

module Ncdc

  class Error < StandardError

    def initialize(message = nil, cause = nil)
      super(message)
    end

    # Include after - so that the 'initialize' method is properly aliased.
    include Util::ChainedError

  end

end