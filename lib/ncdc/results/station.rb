require 'ncdc/client'

require 'ncdc/result'
require 'ncdc/results/wraps_id_and_name'
require 'ncdc/results/wraps_dates'

require 'ncdc/results/data'
require 'ncdc/results/data_category'
require 'ncdc/results/data_set'
require 'ncdc/results/data_type'

module Ncdc

  module Results

    # Represents the details of a station.
    # Additionally also provides methods to query weather information for a station.
    class Station < Ncdc::Result

      # Creates a new station.
      #
      # @param [Hash] details
      # @param [Ncdc::Client] client
      def initialize(details, client)
        super(details)

        @client = client
      end

      # Include after - so that the 'initialize' method is properly aliased.
      include Ncdc::Results::WrapsIdAndName
      include Ncdc::Results::WrapsDates

      # Gets the elevation of this station above sea level (in metres).
      #
      # @return [Numeric]
      def elevation
        @details['elevation']
      end

      # Gets the latitude of this station.
      #
      # @return [Float]
      def latitude
        @details['latitude']
      end

      # Gets the longitude of this station.
      #
      # @return [Float]
      def longitude
        @details['longitude']
      end

      # Gets the data categories for this station.
      #
      # @return [Array<Ncdc::Results::DataCategory>]
      def data_categories
        @client.get_datacategories('stationid' => id)
      end

      # Get the data sets for this station.
      #
      # @return [Array<Ncdc::Results::DataSet>]
      def data_sets
        @client.get_datasets('stationid' => id)
      end

      # Gets the data categories for this station.
      #
      # @return [Array<Ncdc::Results::DataType>]
      def data_types
        @client.get_datatypes('stationid' => id)
      end

      # Gets the specified data for this station.
      # Requests will be split up if the requested date range is more than 1 year.
      #
      # @param [String] set
      # @param [String] type
      # @param [Time] from
      # @param [Time] to
      def get_data(set, type, from, to)
        # First split up the date range into 1 year intervals.
        splits = [from]
        next_date = from + 365.days
        while next_date < to
          splits << next_date
          next_date = next_date + 365.days
        end
        splits << to
        # Then get data for each interval.
        all_results = []
        from_part = splits[0]
        splits[1..-1].each do |to_part|
          start_date = Ncdc::Client.strftime(from_part)
          end_date = Ncdc::Client.strftime(to_part - 1)
          params = {'stationid' => id, 'datasetid' => set, 'datatypeid' => type, 'startdate' => start_date, 'enddate' => end_date}
          all_results += @client.get_data(params)
          from_part = to_part
        end
        # Return the full list of results.
        all_results
      end

      private

    end

  end

end

class Numeric

  def seconds
    self
  end

  def minutes
    self * 60
  end

  def hours
    minutes * 60
  end

  def days
    hours * 24
  end

end
