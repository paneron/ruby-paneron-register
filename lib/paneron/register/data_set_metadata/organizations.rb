# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class DataSetMetadata < Lutaml::Model::Serializable
      class Organizations < Lutaml::Model::Serializable
        attribute :organizations, Paneron::Register::DataSetMetadata::Organizations

        key_value do
          map to: :organizations,
              root_mappings: {
                uuid: :key,
              }
        end
      end
    end
  end
end
