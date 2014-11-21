require 'ncdc/result'
require 'ncdc/results/wraps_id_and_name'

module Ncdc

  module Results

    # Represents the details of a data category.
    class DataCategory < Ncdc::Result

      include Ncdc::Results::WrapsIdAndName

    end

  end

end
