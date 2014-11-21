require 'uri'
require 'json'
require 'logger'
require 'net/http'

require 'ncdc/error'
require 'ncdc/stations'

require 'ncdc/results/data'
require 'ncdc/results/data_category'
require 'ncdc/results/data_set'
require 'ncdc/results/data_type'
require 'ncdc/results/location'
require 'ncdc/results/location_category'
require 'ncdc/results/station'

module Ncdc

  # Wraps all the logic required to connect to and get information from the NCDC server.
  class Client

    # Formats the specified time into a format that NCDC server will understand.
    #
    # @param [Time] time
    def self.strftime(time)
      time.strftime('%Y-%m-%d')
    end

    # Maps data types to their corresponding data classes.
    DATA_CLASSES = {'PRCP' => Ncdc::Results::PrecipitationData, 'SNOW' => Ncdc::Results::SnowfallData,
                    'TMIN' => Ncdc::Results::TemperatureData, 'TMAX' => Ncdc::Results::TemperatureData}

    include Ncdc::Stations

    # The number of records returned from the server each call. Can be number between 1 and 1000. Default is 25.
    attr_accessor :limit

    # New NCDC client.
    #
    # @param [String] token
    def initialize(token)
      @token = token
      @limit = 25
      @base_uri = URI('http://www.ncdc.noaa.gov')
      @api_path = 'cdo-web/api/v2/'

      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN
    end

    # Sends a request to the remote server for 'datasets'.
    #
    # @param [Hash] params
    # @return [Array<Ncdc::Results::DataSet]
    def get_datasets(params = {})
      request_list('datasets', params).map do |details|
        Ncdc::Results::DataSet.new(details)
      end
    end

    # Sends a request to the remote server for 'datasets/#{id}'
    #
    # @param [String] id
    # @param [Hash] params
    # @return [Ncdc::Results::DataSet]
    def get_dataset(id, params = {})
      Ncdc::Results::DataSet.new(request_single('datasets', id, params))
    end

    # Sends a request to the remote server for 'datacategories'.
    #
    # @param [Hash] params
    def get_datacategories(params = {})
      request_list('datacategories', params).map do |details|
        Ncdc::Results::DataCategory.new(details)
      end
    end

    # Sends a request to the remote server for 'datacategory/#{id}'
    #
    # @param [String] id
    # @param [Hash] params
    # @return [Ncdc::Results::DataCategory]
    def get_datacategory(id, params = {})
      Ncdc::Results::DataCategory.new(request_single('datacategories', id, params))
    end

    # Sends a request to the remote server for 'datatypes'.
    #
    # @param [Hash] params
    def get_datatypes(params = {})
      request_list('datatypes', params).map do |details|
        Ncdc::Results::DataType.new(details)
      end
    end

    # Sends a request to the remote server for 'datatypes/#{id}'
    #
    # @param [String] id
    # @param [Hash] params
    # @return [Ncdc::Results::DataType]
    def get_datatype(id, params = {})
      Ncdc::Results::DataType.new(request_single('datatypes', id, params))
    end

    # Sends a request to the remote server for 'data'.
    #
    # @param [Hash] params
    def get_data(params = {})
      request_list('data', params).map do |details|
        DATA_CLASSES.fetch(details.fetch('datatype')).new(details)
      end
    end

    # Sends a request to the remote server for 'locations'
    #
    # @param [Hash] params
    def get_locations(params = {})
      request_list('locations', params).map do |details|
        Ncdc::Results::Location.new(details)
      end
    end

    # Sends a request to the remote server for 'locations/#{id}'
    #
    # @param [String] id
    # @param [Hash] params
    # @return [Ncdc::Results::Location]
    def get_location(id, params = {})
      Ncdc::Results::Location.new(request_single('locations', id, params))
    end

    # Sends a request to the remote server for 'locationcategories'
    #
    # @param [Hash] params
    def get_locationcategories(params = {})
      request_list('locationcategories', params).map do |details|
        Ncdc::Results::LocationCategory.new(details)
      end
    end

    # Sends a request to the remote server for 'locationcategories/#{id}'
    #
    # @param [String] id
    # @param [Hash] params
    # @return [Ncdc::Results::LocationCategory]
    def get_locationcategory(id, params = {})
      Ncdc::Results::LocationCategory.new(request_single('locationcategories', id, params))
    end

    # Sends a request to the remote server for 'stations'
    #
    # @param [Hash] params
    def get_stations(params = {})
      request_list('stations', params) do |details|
        Ncdc::Results::Station.new(details, self)
      end
    end

    # Sends a request to the remote server for 'stations/#{id}'
    #
    # @param [String] id
    # @param [Hash] params
    # @return [Ncdc::Results::Station]
    def get_station(id, params = {})
      Ncdc::Results::Station.new(request_single('stations', id, params), self)
    end

    # Updates the logging level for the client.
    #
    # @param [String] level
    def logging=(level)
      @logger.level = level
    end

    # Requests for the specified data from the server.
    # Will query the server multiple times to get all pages.
    #
    # @param [String] item
    # @param [Hash] params
    # @return [Array<Hash>]
    def request_list(item, params = {})
      @logger.info("Request : #{item}")
      @logger.info("Params : #{params.inspect}")

      offset = 1
      all_results = []
      while true
        params['offset'] = offset
        response = request_raw(item, params)
        break if response.empty?
        all_results += response['results']
        # Check the metadata to see if there are more results to fetch.
        metadata = response['metadata']['resultset']
        limit = metadata['limit']
        count = metadata['count']
        offset = metadata['offset'] + limit
        break if offset >= count
      end
      # Return combined results.
      all_results
    end

    # Requests for the specified data from the server.
    #
    # @param [String] item
    # @param [String] id
    # @param [Hash] params
    # @return [Hash]
    def request_single(item, id, params = {})
      @logger.info("Request : #{item}")
      @logger.info("Params : #{params.inspect}")

      details = request_raw("#{item}/#{id}", params)
      raise Ncdc::Error.new("Request for '#{item}/#{id}' failed - no data") if details.empty?
      details
    end

    private

    # Builds the parameters hash adding in default values.
    #
    # @param [Hash] overrides
    # @return [Hash]
    def __build_parameters__(overrides)
      defaults = {'limit' => @limit}
      defaults.merge(overrides)
    end

    # Builds a request for the specified item and parameters.
    #
    # @param [String] item
    # @param [Hash] params
    # @return [Net::HTTPRequest]
    def __build_request__(item, params)
      uri = URI.join(@base_uri, @api_path, item)
      uri.query = params.map { |key, value| "#{key}=#{value}" }.join('&')
      request = Net::HTTP::Get.new(uri.to_s)
      request['token'] = @token
      request
    end

    # Sends a request to the specified http server. Processes the response and returns the results and metadata.
    # Exception is raised if the request failed.
    #
    # @param [Net::HTTP] http
    # @param [Net::HTTPRequest] request
    def __send_request__(http, request)
      @logger.debug("HTTP.request(#{request.path})")

      response = http.request(request)
      results = JSON.parse(response.body)
      if response.kind_of?(Net::HTTPOK)
        results
      else
        code = results['status']
        message = results['developerMessage']
        message = results['message'] if message.nil?
        raise Ncdc::Error.new("Request for '#{request.path}' failed - #{code} #{response.message} : #{message}")
      end
    end

    # Convenience method for sending a request to the remote server. A new HTTP connection is created each time.
    #
    # @param [String] item
    # @param [Hash] params
    def request_raw(item, params)
      with_http { |http| __send_request__(http, __build_request__(item, __build_parameters__(params))) }
    end

    # Executes the specified block using an HTTP connection. The connection is closed when the block exits.
    #
    # @param [Proc] block
    def with_http(&block)
      Net::HTTP.start(@base_uri.host, @base_uri.port, &block)
    end

  end

end
