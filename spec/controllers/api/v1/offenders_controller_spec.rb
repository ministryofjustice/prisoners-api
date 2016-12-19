require 'rails_helper'

RSpec.describe Api::V1::OffendersController, type: :controller do
  let!(:application) { create(:application) }
  let!(:token)       { create(:access_token, application: application) }

  let!(:offender_1) do
    create(:offender, noms_id: 'A1234BC')
  end

  let!(:offender_2) do
    create(:offender, noms_id: 'A9876ZX')
  end

  let!(:offender_3) do
    create(:offender, noms_id: 'A4567FG')
  end

  let!(:offender_4) do
    create(:offender, noms_id: 'A9999XX')
  end

  let!(:identity_1) do
    create(:identity, offender: offender_1, status: 'active')
  end

  let!(:identity_2) do
    create(:identity, offender: offender_2, status: 'active')
  end

  let!(:identity_3) do
    create(:identity, offender: offender_3, status: 'active')
  end

  let!(:identity_4) do
    create(:identity, offender: offender_3, status: 'inactive')
  end

  before do
    offender_1.update_attributes current_identity: identity_1, updated_at: 1.year.ago
    offender_2.update_attributes current_identity: identity_2, updated_at: 5.days.ago
    offender_3.update_attributes current_identity: identity_3, updated_at: 20.days.ago
    offender_4.update_attributes current_identity: identity_4, updated_at: 2.days.ago
  end

  context 'when authenticated' do
    before { request.headers['HTTP_AUTHORIZATION'] = "Bearer #{token.token}" }

    describe 'GET #index' do
      it 'returns collection of offender records' do
        get :index

        expect(JSON.parse(response.body).map { |h| h['id'] })
          .to match_array(Offender.active.pluck(:id))
      end

      it 'paginates records' do
        get :index, page: '1', per_page: '2'

        expect(JSON.parse(response.body).size).to eq 2
      end

      it 'sets total count in response headers' do
        get :index

        expect(response.headers['Total-Count']).to eq '3'
      end

      it 'scopes active offenders' do
        get :index

        expect(JSON.parse(response.body).size).to eq 3
      end

      it 'filters records updated after a timestamp' do
        get :index, updated_after: 10.days.ago

        expect(JSON.parse(response.body).size).to eq 1
      end
    end

    describe 'GET #search' do
      context 'searching for NOMS ID' do
        context 'when query matches' do
          let(:search_params) { { noms_id: 'A1234BC' } }

          before { get :search, search_params }

          it 'returns collection of offender records matching query' do
            expect(JSON.parse(response.body).map { |p| p['id'] })
              .to match_array([offender_1['id']])
          end
        end

        context 'when query does not match' do
          let(:search_params) { { noms_id: 'A4321KL' } }

          before { get :search, search_params }

          it 'returns an empty set' do
            expect(response.body).to eq('[]')
          end
        end
      end

      it 'paginates records' do
        get :search, page: '1', per_page: '2'

        expect(JSON.parse(response.body).size).to eq 2
      end

      it 'sets total count in response headers' do
        get :search

        expect(response.headers['Total-Count']).to eq '3'
      end

      it 'scopes active offenders' do
        get :search

        expect(JSON.parse(response.body).size).to eq 3
      end
    end

    describe 'GET #show' do
      let(:offender) { create(:offender) }

      before { get :show, id: offender }

      it 'returns status 200' do
        expect(response.status).to be 200
      end

      it 'returns JSON represenation of offender record' do
        expect(JSON.parse(response.body).as_json)
          .to include offender.as_json(except: %w(date_of_birth created_at updated_at current_identity_id))
      end
    end
  end

  context 'when unauthenticated' do
    describe 'GET #index' do
      before { get :index }

      it 'returns status 401' do
        expect(response.status).to be 401
      end
    end

    describe 'GET #search' do
      before { get :search, query: '' }

      it 'returns status 401' do
        expect(response.status).to be 401
      end
    end

    describe 'GET #show' do
      before { get :show, id: 1 }

      it 'returns status 401' do
        expect(response.status).to be 401
      end
    end
  end
end
