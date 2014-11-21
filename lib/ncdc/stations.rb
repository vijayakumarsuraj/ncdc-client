require 'ncdc/results/station'

module Ncdc

  module Stations

    # Gets the 'Bombay' station - GHCND:IN012070800
    #
    # @return [Ncdc::Results::Station]
    def station_bombay
      get_station('GHCND:IN012070800')
    end

    # Gets the 'Minneapolis' station - GHCND:USW00014922
    #
    # @return [Ncdc::Results::Station]
    def station_minneapolis
      get_station('GHCND:USW00014922')
    end

    # Gets the 'New Delhi' station - GHCND:IN022021900
    #
    # @return [Ncdc::Results::Station]
    def station_new_delhi
      get_station('GHCND:IN022021900')
    end

    # Gets the 'NorthYork' station - GHCND:CA00615S001
    #
    # @return [Ncdc::Results::Station]
    def station_north_york
      get_station('GHCND:CA00615S001')
    end

    # Gets the 'Toronto' station - GHCND:CA006158350
    #
    # @return [Ncdc::Results::Station]
    def station_toronto
      get_station('GHCND:CA006158350')
    end

  end

end
