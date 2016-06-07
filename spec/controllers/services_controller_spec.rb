require 'rails_helper'

RSpec.describe ServicesController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET #index' do
    before { get :index }

    it 'should return status 200' do
      expect(response.status).to eq(200)
    end

    it 'should render the index template' do
      expect(response).to render_template(:index)
    end
  end
end