# frozen_string_literal: true

##
#
# System::DomainsController
#
# Checks to see if the domain exists in the database
# when the domain and returns the correct status code.
#
class System::DomainsController < ApplicationController
  def check
    domain = params[:domain]
    if domain
      status = Domain.exists?(host: domain) ? :ok : :not_found
      head status
    else
      head :not_found
    end
  end
end
