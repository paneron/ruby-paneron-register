# frozen_string_literal: true

module Paneron
  module Register
    module Hierarchical
      # def self.included(base)
      #   base.class_eval do
      #   end
      # end
      # Split into parent path and base name

      def self.split_path(full_path)
        # {
        #   parent_path: File.dirname(full_path),
        #   basename: File.basename(full_path),
        # }
        [
          File.dirname(full_path),
          File.basename(full_path),
        ]
      end
    end
  end
end
