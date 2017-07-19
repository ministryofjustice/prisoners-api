require 'rails_helper'

RSpec.describe ParseOffenders do
  let(:excel_data) { fixture_file_upload('files/data.xls', 'application/vnd.ms-excel') }

  describe '#call' do
    context 'when parsing offenders' do
      context 'when offenders do not exist in local database' do
        before { described_class.call(excel_data) }

        it 'creates offender records' do
          expect(Offender.count).to eq(2)
        end

        it 'creates identities records' do
          expect(Identity.count).to eq(3)
        end

        it 'imports all the fields correctly for the offender' do
          offender = Offender.find_by!(noms_id: 'A1234BC')

          expect(offender.given_name_1).to eq('LARRY')
          expect(offender.given_name_2).to eq('MARK')
          expect(offender.given_name_3).to eq('JOE')
          expect(offender.surname).to eq('LATITUDE')
          expect(offender.title).to eq('MR')
          expect(offender.date_of_birth).to eq(Date.civil(1970, 1, 30))
          expect(offender.gender).to eq('M')
          expect(offender.pnc_number).to eq('05/103329A')
          expect(offender.nationality_code).to eq('BRIT')
          expect(offender.cro_number).to eq('309129/05R')
          expect(offender.establishment_code).to eq('LEI')
          expect(offender.ethnicity_code).to eq('W1')
        end

        it 'imports all the fields correctly for the identity' do
          identity = Identity.find_by!(nomis_offender_id: '1055829'.to_i)

          expect(identity.noms_id).to eq('A1234BC')
          expect(identity.nomis_offender_id).to eq('1055829'.to_i)
          expect(identity.given_name_1).to eq('JOHN')
          expect(identity.given_name_2).to eq('LUKE')
          expect(identity.given_name_3).to eq('FRANK')
          expect(identity.surname).to eq('DOE')
          expect(identity.title).to eq('MR')
          expect(identity.date_of_birth).to eq(Date.civil(1980, 2, 20))
          expect(identity.gender).to eq('M')
          expect(identity.pnc_number).to eq('07/3862805R')
          expect(identity.nationality_code).to eq('BRIT')
          expect(identity.cro_number).to eq('339223/02H')
          expect(identity.establishment_code).to eq('LEI')
          expect(identity.ethnicity_code).to eq('B1')
          expect(identity.status).to eq('active')
        end
      end

      context 'when offenders exist in local database' do
        before do
          offender_one = create(:offender, noms_id: 'A1234BC')
          offender_two = create(:offender, noms_id: 'A1234BU')
          create(:identity, offender: offender_one, nomis_offender_id: '1056827'.to_i)
          create(:identity, offender: offender_one, nomis_offender_id: '1055829'.to_i)
          create(:identity, offender: offender_two, nomis_offender_id: '1055847'.to_i)
          described_class.call(excel_data)
        end

        it 'does not create new offender records' do
          expect(Offender.count).to eq(2)
        end

        it 'does not create new identities records' do
          expect(Identity.count).to eq(3)
        end

        it 'updates all the fields correctly for the offender' do
          offender = Offender.find_by!(noms_id: 'A1234BC')

          expect(offender.given_name_1).to eq('LARRY')
          expect(offender.given_name_2).to eq('MARK')
          expect(offender.given_name_3).to eq('JOE')
          expect(offender.surname).to eq('LATITUDE')
          expect(offender.title).to eq('MR')
          expect(offender.date_of_birth).to eq(Date.civil(1970, 1, 30))
          expect(offender.gender).to eq('M')
          expect(offender.pnc_number).to eq('05/103329A')
          expect(offender.nationality_code).to eq('BRIT')
          expect(offender.cro_number).to eq('309129/05R')
          expect(offender.establishment_code).to eq('LEI')
          expect(offender.ethnicity_code).to eq('W1')
        end

        it 'updates all the fields correctly for the identity' do
          identity = Identity.find_by!(nomis_offender_id: '1055829'.to_i)

          expect(identity.noms_id).to eq('A1234BC')
          expect(identity.nomis_offender_id).to eq('1055829'.to_i)
          expect(identity.given_name_1).to eq('JOHN')
          expect(identity.given_name_2).to eq('LUKE')
          expect(identity.given_name_3).to eq('FRANK')
          expect(identity.surname).to eq('DOE')
          expect(identity.title).to eq('MR')
          expect(identity.date_of_birth).to eq(Date.civil(1980, 2, 20))
          expect(identity.gender).to eq('M')
          expect(identity.pnc_number).to eq('07/3862805R')
          expect(identity.nationality_code).to eq('BRIT')
          expect(identity.cro_number).to eq('339223/02H')
          expect(identity.establishment_code).to eq('LEI')
          expect(identity.ethnicity_code).to eq('B1')
        end
      end
    end

    context 'invalid Excel data' do
      context 'with invalid records' do
        let(:excel_data) { fixture_file_upload('files/invalid_data.xls', 'application/vnd.ms-excel') }

        it 'returns an array with 3 hashes' do
          errors = described_class.call(excel_data)
          expect(errors.size).to eq 3
          expect(errors.all? { |e| e.is_a?(Hash) }).to be true
        end
      end
    end
  end
end
