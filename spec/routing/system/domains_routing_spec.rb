# frozen_string_literal: true

RSpec.describe System::DomainsController, type: :routing do
  it 'routes to #domain_check' do
    expect(get("https://system.#{Settings.host}/domain_check")).to route_to('system/domains#check', controller: 'domains', action: 'check')
  end
end
