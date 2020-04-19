# frozen_string_literal: true

RSpec.describe 'domains/index', type: :view do
  before(:each) do
    assign(:domains, [
             Domain.create!(
               host: 'Host',
               origin: 'Origin',
               verified: false
             ),
             Domain.create!(
               host: 'Host',
               origin: 'Origin',
               verified: false
             )
           ])
  end

  it 'renders a list of domains' do
    render
    assert_select 'tr>td', text: 'Host'.to_s, count: 2
    assert_select 'tr>td', text: 'Origin'.to_s, count: 2
    assert_select 'tr>td', text: false.to_s, count: 2
  end
end
