# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class DataSet < Lutaml::Model::Serializable
      attribute :name, Lutaml::Model::Type::String
      attribute :item_classes, Paneron::Register::ItemClass, collection: true

      attribute :metadata, Paneron::Register::DataSetMetadata
      attribute :paneron_metadata, Paneron::Register::PaneronMetadata
    end
  end
end
