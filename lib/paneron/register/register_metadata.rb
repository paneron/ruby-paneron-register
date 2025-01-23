# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class RegisterMetadata < Lutaml::Model::Serializable
      attribute :title, Lutaml::Model::Type::String
      attribute :datasets, Paneron::Register::RegisterMetadata::Datasets
    end
  end
end
