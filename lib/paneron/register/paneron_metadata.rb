# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class PaneronMetadata < Lutaml::Model::Serializable
      attribute :title, Lutaml::Model::Type::String
      attribute :type, Paneron::Register::PaneronMetadata::DataSetType
    end
  end
end
