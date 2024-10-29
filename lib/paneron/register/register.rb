require "lutaml/model"

module Paneron
  module Register
    class Register < Lutaml::Model::Serializable
      attribute :name, Lutaml::Model::Type::String
      attribute :item_classes, Paneron::Register::ItemClass, collection: true
    end
  end
end
