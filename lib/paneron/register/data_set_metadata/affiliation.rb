# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class DataSetMetadata < Lutaml::Model::Serializable
      class Affiliation < Lutaml::Model::Serializable
        attribute :uuid, Lutaml::Model::Type::String
        attribute :role, Lutaml::Model::Type::String,
                  values: %w[
                    pointOfContact
                    member
                  ]
      end
    end
  end
end
