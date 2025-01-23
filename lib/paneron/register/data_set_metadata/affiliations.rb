# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class DataSetMetadata < Lutaml::Model::Serializable
      class Affiliations < Lutaml::Model::Serializable
        attribute :affiliations, Paneron::Register::DataSetMetadata::Affiliation,
                  collection: true

        key_value do
          map to: :affiliations,
              root_mappings: {
                uuid: :key,
              }
        end
      end
    end
  end
end
