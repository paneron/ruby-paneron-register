# frozen_string_literal: true

require "yaml"

require "lutaml/model"

module Paneron
  module Register
    class RegisterRoot < Lutaml::Model::Serializable
      attribute :registers, Paneron::Register::Register, collection: true
      attribute :metadata, Lutaml::Model::Type::String
    end
  end
end
