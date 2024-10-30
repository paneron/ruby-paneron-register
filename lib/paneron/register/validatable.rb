# frozen_string_literal: true

module Paneron
  module Register
    module Validatable
      def path_valid?
        self.class.validate_path(self_path)
        true
      rescue Paneron::Register::Error => e
        errors << e.message
        warn "#{self.class.name} is not path-valid:\n#{errors.map do |e|
          "  - #{e}"
        end.join("\n")}"
        false
      end

      def valid?
        @errors = []
        # Taking advantage of side-effects in #is_valid?
        # before validate_path happens:
        is_valid?
      rescue Paneron::Register::Error => e
        errors << e.message
        warn "#{self.class.name} is not valid:\n#{errors.map do |e|
          "  - #{e}"
        end.join("\n")}"
        false
      end

      def errors
        @errors ||= []
      end
    end
  end
end
