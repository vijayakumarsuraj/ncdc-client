require 'ncdc/result'
require 'ncdc/results/wraps_id_and_name'

module Ncdc

  module Results

    # Represents the details of a location category.
    class LocationCategory < Ncdc::Result

      include Ncdc::Results::WrapsIdAndName

    end

  end

end
