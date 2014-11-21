require 'date'

require 'ncdc/error'

module Ncdc

  module Results

    # A wrapper for the 'maxdate' and 'mindate' attribute.
    module WrapsDates

      def self.included(base)
        base.send(:alias_method, :initialize_without_dates, :initialize)
        base.send(:alias_method, :initialize, :initialize_with_dates)
      end

      # The value of the attribute 'maxdate'
      attr_reader :end_date
      # The value of the attribute 'mindate'
      attr_reader :start_date

      # Chained override for initializing the 'mindate' and 'maxdate' attributes.
      def initialize_with_dates(details, *args)
        initialize_without_dates(details, *args)


        end_date = @details.fetch('maxdate') rescue raise(Ncdc::Error.new("Could not read attribute 'maxdate' - #{details.inspect}", $!))
        @end_date = Date.parse(end_date) rescue raise(Ncdc::Error.new("Invalid value for attribute 'maxdate' : #{end_date}", $!))

        start_date = @details.fetch('mindate') rescue raise(Ncdc::Error.new("Required attribute 'mindate' not found - #{details.inspect}", $!))
        @start_date = Date.parse(start_date) rescue raise(Ncdc::Error.new("Invalid value for attribute 'mindate' : #{start_date}", $!))
      end

    end

  end

end
