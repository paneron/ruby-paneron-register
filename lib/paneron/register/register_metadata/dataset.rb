# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class RegisterMetadata < Lutaml::Model::Serializable
      class Dataset < Lutaml::Model::Serializable
        attribute :data_set_name, Lutaml::Model::Type::String
        attribute :data_set_available, Lutaml::Model::Type::Boolean, default: -> { true }
      end
    end
  end
end
