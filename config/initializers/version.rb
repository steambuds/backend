# frozen_string_literal: true

module SteamBuds
  module Backend
    class << self
      def version
        @version ||= begin
          # Try to get version from environment variable (set during Docker build)
          env_version = ENV.fetch("APP_VERSION", nil)
          return env_version if env_version.present?

          # Try to get version from git (for development)
          git_version = `git describe --tags --always 2>/dev/null`.strip
          return git_version if git_version.present? && $?.success?

          # Fallback to unknown
          "unknown"
        end
      end

      def revision
        @revision ||= begin
          # Try to get git SHA from environment variable (set during Docker build)
          env_sha = ENV.fetch("GIT_SHA", nil)
          return env_sha if env_sha.present?

          # Try to get SHA from git (for development)
          git_sha = `git rev-parse --short HEAD 2>/dev/null`.strip
          return git_sha if git_sha.present? && $?.success?

          # Fallback to unknown
          "unknown"
        end
      end
    end
  end
end
