# frozen_string_literal: true

module Paneron
  module Register
    module Writeable
      def save
        unless parent.nil? || parent.path_valid?
          raise Paneron::Register::Error, "Parent (#{parent.class.name}) is not valid"
        end

        if valid?
          save_sequence
          if !git_client.nil?
            git_client.add
            if git_client.status.added.any?
              git_client.commit("Update #{self.class.name}, from ruby-paneron-register")
            end
          end
        else
          raise Paneron::Register::Error, "#{self.class.name} is not valid:\n#{errors.map do |e|
            "  - #{e}"
          end.join("\n")}"
        end
      end

      def remote?
        !git_url.nil? && git_url != ""
      end

      # Sync to remote
      # @param [Boolean] update If true, rebase and pull before pushing
      def sync(update: false, message: nil)
        if remote?
          if update
            git_client.pull(
              nil, nil, rebase: true
            )
          end
          git_client.add
          if git_client.status.added.any?
            git_client.commit(message.nil? ? "Sync from ruby-paneron-register" : message)
          end
          git_client.push
        else
          raise Paneron::Register::Error, "Cannot sync without a remote"
        end
      end
    end
  end
end
