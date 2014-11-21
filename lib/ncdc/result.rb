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

    # Overridden to query the 'details' hash for the specified key.
    # If the key exists, returns the value of that key. Otherwise uses the default behaviour.
    #
    # @param [Symbol] method
    # @param [Array] args
    # @param [Proc] block
    def method_missing(method, *args, &block)
      key = method.to_s
      return @details[key] if @details.has_key?(key)

      raise Ncdc::Error.new("Could not read attribute '#{key}' - #{@details.inspect}")
    end

  end

end
