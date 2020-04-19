# frozen_string_literal: true

RSpec.describe System::DomainsController, type: :controller do
  let(:domain) { FactoryBot.create(:domain) }

  describe 'GET #check' do
    context 'when a domain is found' do
      it 'returns 200' do
        get :check, params: { domain: domain.host }
        expect(response).to have_http_status(:success)
      end
    end

    context 'when a domain is not found' do
      it 'returns 404' do
        get :check, params: { domain: 'www.google.com' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when a param is not given' do
      it 'returns 404' do
        get :check
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
