module Util

  # Include into errors to support chained errors.
  module ChainedError

    def self.included(base)
      base.send(:alias_method, :initialize_without_chain, :initialize)
      base.send(:alias_method, :initialize, :initialize_with_chain)

      base.send(:alias_method, :message_without_chain, :message)
      base.send(:alias_method, :message, :message_with_chain)

      base.send(:alias_method, :set_backtrace_without_chain, :set_backtrace)
      base.send(:alias_method, :set_backtrace, :set_backtrace_with_chain)
    end

    # New error.
    #
    # @param [String] message the message.
    # @param [StandardError] cause the nested cause of the error.
    def initialize_with_chain(message = nil, cause = nil)
      initialize_without_chain(message)

      @cause = cause
    end

    # Overridden to return the message associated with the nested exception also.
    #
    # @return [String]
    def message_with_chain
      @cause.nil? ? message_without_chain : "#{message_without_chain} (cause: #{@cause.message})"
    end

    # Overridden to update the backtrace to include the nested exception's backtrace also.
    def set_backtrace_with_chain(bt)
      if @cause
        # We remove all lines of the nested exception's backtrace that intersect with
        # this exception's backtrace.
        @cause.backtrace.reverse.each { |line| bt.last == line ? bt.pop : break }
        # Add the nested exception's message and back trace to this exception's backtrace.
        bt << "cause: #{@cause} (#{@cause.class.name})"
        bt.concat @cause.backtrace
      end
      #
      set_backtrace_without_chain(bt)
    end

  end

end
