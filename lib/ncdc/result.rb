require 'ncdc/error'

module Ncdc

  # The base class for all "results" returned by the NCDC server.
  # All this class does is provide a wrapper for the Hash that represents each result.
  class Result

    # New result.
    #
    # @param [Hash] details
    def initialize(details)
      @details = details
    end

  end

end
