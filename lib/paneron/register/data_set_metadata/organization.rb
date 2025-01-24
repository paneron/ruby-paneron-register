# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class DataSetMetadata < Lutaml::Model::Serializable
      class Organization < Lutaml::Model::Serializable
        attribute :uuid, Lutaml::Model::Type::String
        attribute :name, Lutaml::Model::Type::String
        attribute :logoURL, Lutaml::Model::Type::String, default: -> { "" }
      end
    end
  end
end
