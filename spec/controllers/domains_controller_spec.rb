# frozen_string_literal: true

RSpec.describe DomainsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Domain. As you add validations to Domain, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      host: 'app.com',
      origin: 'ezoic.com'
    }
  end

  let(:invalid_attributes) do
    {
      host: '',
      origin: ''
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DomainsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'returns a success response' do
      Domain.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      domain = Domain.create! valid_attributes
      get :show, params: { id: domain.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: {}, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      domain = Domain.create! valid_attributes
      get :edit, params: { id: domain.to_param }, session: valid_session
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Domain' do
        expect do
          post :create, params: { domain: valid_attributes }, session: valid_session
        end.to change(Domain, :count).by(1)
      end

      it 'redirects to the created domain' do
        post :create, params: { domain: valid_attributes }, session: valid_session
        expect(response).to redirect_to(Domain.last)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { domain: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          host: 'newapp.com',
          origin: 'tesla.com'
        }
      end

      it 'updates the requested domain' do
        domain = Domain.create! valid_attributes
        put :update, params: { id: domain.to_param, domain: new_attributes }, session: valid_session
        domain.reload
        expect(domain.host).to eql new_attributes[:host]
        expect(domain.origin).to eql new_attributes[:origin]
      end

      it 'redirects to the domain' do
        domain = Domain.create! valid_attributes
        put :update, params: { id: domain.to_param, domain: valid_attributes }, session: valid_session
        expect(response).to redirect_to(domain)
      end
    end

    context 'with invalid params' do
      it "returns a success response (i.e. to display the 'edit' template)" do
        domain = Domain.create! valid_attributes
        put :update, params: { id: domain.to_param, domain: invalid_attributes }, session: valid_session
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested domain' do
      domain = Domain.create! valid_attributes
      expect do
        delete :destroy, params: { id: domain.to_param }, session: valid_session
      end.to change(Domain, :count).by(-1)
    end

    it 'redirects to the domains list' do
      domain = Domain.create! valid_attributes
      delete :destroy, params: { id: domain.to_param }, session: valid_session
      expect(response).to redirect_to(domains_url)
    end
  end
end
