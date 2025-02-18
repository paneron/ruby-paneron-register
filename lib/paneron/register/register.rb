# frozen_string_literal: true

require "lutaml/model"

module Paneron
  module Register
    class Register < Lutaml::Model::Serializable
      attribute :data_sets, Paneron::Register::DataSet, collection: true
      attribute :metadata, Paneron::Register::RegisterMetadata
    end
  end
end
