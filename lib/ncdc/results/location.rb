require 'ncdc/result'
require 'ncdc/results/wraps_id_and_name'
require 'ncdc/results/wraps_dates'

module Ncdc

  module Results

    # Represents the details of a location.
    class Location < Ncdc::Result

      include Ncdc::Results::WrapsIdAndName
      include Ncdc::Results::WrapsDates

    end

  end

end
