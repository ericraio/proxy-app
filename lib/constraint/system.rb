# frozen_string_literal: true

module Constraint
  ##
  # Constraint::System.
  #
  # Responsible for ensuring that the incoming requests are constrained to
  # the system subdomain and the host that was configured in the settings.
  #
  class System
    def self.matches?(request)
      subdomain = request.subdomain
      return false if subdomain.blank?

      host = request.host
      host.end_with?(Settings.host) && %w[system].include?(subdomain)
    end
  end
end
