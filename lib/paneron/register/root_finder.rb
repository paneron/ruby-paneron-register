# frozen_string_literal: true

module Paneron
  module Register
    module RootFinder
      # def self.included(base)
      #   base.class_eval do
      #   end
      # end

      def register
        parent.register
      end

      def git_client
        parent.git_client
      end

      def git_url
        parent.git_url
      end
    end
  end
end
