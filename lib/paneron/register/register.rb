# frozen_string_literal: true

require "yaml"

require "lutaml/model"

module Paneron
  module Register
    class Register < Lutaml::Model::Serializable
      attribute :data_sets, Paneron::Register::DataSet, collection: true
      attribute :metadata, Lutaml::Model::Type::String
    end
  end
end
