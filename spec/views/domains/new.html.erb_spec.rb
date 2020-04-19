# frozen_string_literal: true

RSpec.describe 'domains/new', type: :view do
  before(:each) do
    assign(:domain, Domain.new(
                      host: 'MyString',
                      origin: 'MyString',
                      verified: false
                    ))
  end

  it 'renders new domain form' do
    render

    assert_select 'form[action=?][method=?]', domains_path, 'post' do
      assert_select 'input[name=?]', 'domain[host]'

      assert_select 'input[name=?]', 'domain[origin]'

      assert_select 'input[name=?]', 'domain[verified]'
    end
  end
end
