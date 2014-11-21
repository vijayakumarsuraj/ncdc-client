require 'time'

require 'ncdc/result'

module Ncdc

  module Results

    # Base class for actual weather data.
    class Data < Ncdc::Result

      # The type of the reading. Usually, specific sub-classes of each type should be used.
      attr_reader :type
      # The value of this data.
      attr_reader :value
      # The date of the reading.
      attr_reader :date

      # New data.
      #
      # @param [Hash] details
      def initialize(details)
        super(details)

        @type = details.fetch('datatype')
        @value = details.fetch('value')
        @date = Time.parse(details.fetch('date'))
      end

    end

    # Represents precipitation data.
    class PrecipitationData < Ncdc::Results::Data

      # New precipitation data.
      #
      # @param [Hash] details
      def initialize(details)
        super(details)

        @value = @value / 10.0
      end

    end

    # Represents snowfall data.
    class SnowfallData < Ncdc::Results::Data

      # New snow fall data.
      #
      # @param [Hash] details
      def initialize(details)
        super(details)
      end

    end

    # Represents temperature data.
    class TemperatureData < Ncdc::Results::Data

      # New temperature data.
      #
      # @param [Hash] details
      def initialize(details)
        super(details)

        @value = @value / 10.0
      end

    end

  end

end
