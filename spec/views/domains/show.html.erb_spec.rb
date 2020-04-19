# frozen_string_literal: true

RSpec.describe 'domains/show', type: :view do
  before(:each) do
    @domain = assign(:domain, Domain.create!(
                                host: 'Host',
                                origin: 'Origin',
                                verified: false
                              ))
  end

  it 'renders attributes in <p>' do
    render
    expect(rendered).to match(/Host/)
    expect(rendered).to match(/Origin/)
    expect(rendered).to match(/false/)
  end
end
