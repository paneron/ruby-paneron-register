# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class DataSetMetadata < Lutaml::Model::Serializable
      class Version < Lutaml::Model::Serializable
        attribute :id, Lutaml::Model::Type::String
        attribute :timestamp, Lutaml::Model::Type::DateTime
      end
    end
  end
end
