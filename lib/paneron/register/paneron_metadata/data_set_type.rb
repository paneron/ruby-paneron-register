# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class PaneronMetadata < Lutaml::Model::Serializable
      class DataSetType < Lutaml::Model::Serializable
        attribute :id, Lutaml::Model::Type::String
        attribute :version, Lutaml::Model::Type::String
      end
    end
  end
end
