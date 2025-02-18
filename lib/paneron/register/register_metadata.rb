# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class RegisterMetadata < Lutaml::Model::Serializable
      attribute :title, Lutaml::Model::Type::String
      attribute :datasets, Paneron::Register::RegisterMetadata::Dataset, collection: true

      key_value do
        map to: :datasets,
            root_mappings: {
              data_set_name: :key,
              data_set_available: :value,
            }
      end
    end
  end
end
