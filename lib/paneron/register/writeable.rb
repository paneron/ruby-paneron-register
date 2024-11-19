# frozen_string_literal: true

module Paneron
  module Register
    module Writeable
      # def self.included(base)
      #   base.class_eval do
      #   end
      # end

      # @return [Paneron::Register::Raw::Register] self
      def save
        unless parent.nil? || parent.path_valid?
          raise Paneron::Register::Error, "Parent (#{parent.class.name}) is not valid"
        end

        if valid?
          save_sequence
          if !git_client.nil?
            add_changes_to_staging
            if has_uncommited_changes?
              commit_changes("Update #{self.class.name}, from ruby-paneron-register")
            end
          end
        else
          raise Paneron::Register::Error, "#{self.class.name} is not valid:\n#{errors.map do |e|
            "  - #{e}"
          end.join("\n")}"
        end

        self
      end

      def remote?
        !git_url.nil? && git_url != ""
      end

      def pull_from_remote
        git_client.pull(
          nil, nil, rebase: true
        )
      end

      def add_changes_to_staging
        git_client.add
      end

      def has_uncommited_changes?
        git_client.status.added.any?
      end

      def remote_branch_name
        "#{@git_remote_name}/#{@git_branch}"
      end

      def has_unsynced_changes?
        git_client.branches[remote_branch_name].nil? || git_client.branches[remote_branch_name].sha !=
          git_client.gcommit("head").sha
      end

      def commit_changes(message: nil)
        git_client.commit(message.nil? ? "Sync from ruby-paneron-register" : message)
      end

      def push_commits_to_remote
        git_client.push
      end

      # Sync to remote
      # @param [Boolean] update If true, rebase and pull before pushing
      # @param [String] message Commit message
      # @return [Paneron::Register::Raw::Register] self
      def sync(update: false, message: nil)
        if remote?
          if update
            pull_from_remote
          end

          add_changes_to_staging

          if has_uncommited_changes?
            commit_changes(message: message)
          end

          if has_unsynced_changes?
            push_commits_to_remote
          end
        else
          raise Paneron::Register::Error, "Cannot sync without a remote"
        end
      end

      self
    end
  end
end
