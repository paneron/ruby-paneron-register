# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    module Type
      class JSDateISOString < Lutaml::Model::Type::DateTime
        def self.from_yaml(input)
          ::DateTime.parse(input)
        end

        # %L adds milliseconds to the time.
        # %3L makes it precise to 3 digits.
        # This exactly mimics Javascript's Date.toISOString()'s format.
        def to_yaml
          value.strftime("%Y-%m-%dT%H:%M:%S.%3LZ")
        end
      end
    end
  end
end
