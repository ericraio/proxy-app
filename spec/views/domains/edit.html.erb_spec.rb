# frozen_string_literal: true

RSpec.describe 'domains/edit', type: :view do
  before(:each) do
    @domain = assign(:domain, Domain.create!(
                                host: 'MyString',
                                origin: 'MyString',
                                verified: false
                              ))
  end

  it 'renders the edit domain form' do
    render

    assert_select 'form[action=?][method=?]', domain_path(@domain), 'post' do
      assert_select 'input[name=?]', 'domain[host]'

      assert_select 'input[name=?]', 'domain[origin]'

      assert_select 'input[name=?]', 'domain[verified]'
    end
  end
end
