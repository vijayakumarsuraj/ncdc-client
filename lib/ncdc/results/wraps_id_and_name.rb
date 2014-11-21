require 'ncdc/error'

module Ncdc

  module Results

    # A wrapper for the 'id' & 'name' attributes.
    module WrapsIdAndName

      def self.included(base)
        base.send(:alias_method, :initialize_without_id_name, :initialize)
        base.send(:alias_method, :initialize, :initialize_with_id_name)
      end

      # Chained override for checking the 'id' and 'name' attributes.
      def initialize_with_id_name(details, *args)
        initialize_without_id_name(details, *args)

        @details.fetch('id') rescue raise(Ncdc::Error.new("Could not read attribute 'id' - #{details.inspect}", $!))
        @details.fetch('name') rescue raise(Ncdc::Error.new("Could not read attribute 'name' - #{details.inspect}", $!))
      end

      # Overridden to return the id and name.
      #
      # @return [String]
      def inspect
        "#{self.class.name} -> #{id}:#{name}"
      end

    end

  end

end
