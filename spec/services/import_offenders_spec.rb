require 'rails_helper'

RSpec.describe ImportOffenders do
  let(:import) { Import.create(offenders_file: offenders_file) }

  describe '#call' do
    context 'when successful' do
      let(:offenders_file) { fixture_file_upload('files/data.xls', 'application/vnd.ms-excel') }

      it 'calls the parse csv service with the data' do
        expect(ParseOffenders).to receive(:call).with(import.offenders_file.file.file).and_return([])
        ImportOffenders.call(import)
      end

      it 'marks the import successful' do
        ImportOffenders.call(import)
        expect(import.status).to eq('successful')
      end

      it 'removes all other imports' do
        Import.create(offenders_file: offenders_file)
        ImportOffenders.call(import)
        expect(Import.count).to be 1
      end
    end

    context 'when failing' do
      let(:offenders_file) { fixture_file_upload('files/invalid_data.xls', 'application/vnd.ms-excel') }

      it 'marks the import failed' do
        ImportOffenders.call(import)
        expect(import.status).to eq('failed')
      end

      it 'saves the errors' do
        expected_log = [
          {
            'noms_id' => nil,
            'nomis_offender_id' => 1_056_827.0,
            'date_of_birth' => '1970-01-30',
            'given_name_1' => 'LARRY',
            'given_name_2' => 'MARK',
            'given_name_3' => 'JOE',
            'surname' => 'LATITUDE',
            'title' => 'MR',
            'gender' => 'M',
            'pnc_number' => '05/103329A',
            'nationality_code' => 'BRIT',
            'cro_number' => '309129/05R',
            'establishment_code' => 'LEI',
            'ethnicity_code' => 'B1',
            'working_name' => 'Y'
          },
          {
            'noms_id' => 'A1234BU',
            'nomis_offender_id' => 1_055_829.0,
            'date_of_birth' => '1980-02-20',
            'given_name_1'  => nil,
            'given_name_2' => 'LUKE',
            'given_name_3' => 'FRANK',
            'surname' => 'DOE',
            'title' => 'MR',
            'gender' => 'M',
            'pnc_number' => '07/3862805R',
            'nationality_code' => 'BRIT',
            'cro_number' => '339223/02H',
            'establishment_code' => 'LEI',
            'ethnicity_code' => 'W1',
            'working_name' => 'N'
          },
          {
            'noms_id' => 'A1234CD',
            'nomis_offender_id' => 1_055_847.0,
            'date_of_birth' => '1990-03-10',
            'given_name_1' => 'BOB',
            'given_name_2' => 'ROBERT',
            'given_name_3' => nil,
            'surname' => 'DYLAN',
            'title' => 'MR',
            'gender' => nil,
            'pnc_number' => '04/837105K',
            'nationality_code' => 'BRIT',
            'cro_number' => '378468/01T',
            'establishment_code' => 'BXI',
            'ethnicity_code' => 'A1',
            'working_name' => 'Y'
          }
        ]

        ImportOffenders.call(import)
        expect(JSON.parse(import.error_log)).to eq(expected_log)
      end

      it 'sends an email' do
        expect { ImportOffenders.call(import) }
          .to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
  end
end
