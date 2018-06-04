require 'rails_helper'

RSpec.describe ImportOffenders do
  let(:import) { Import.create(nomis_exports: [nomis_export]) }

  describe '#call' do
    context 'when successful' do
      let(:nomis_export) { fixture_file_upload('files/data_1.csv', 'text/csv') }

      it 'calls the parse csv service with the data' do
        expect(ParseOffenders).to receive(:call).with(import.nomis_exports.first.file.file).and_return([])
        ImportOffenders.call(import)
      end

      it 'marks the import successful' do
        ImportOffenders.call(import)
        expect(import.status).to eq('successful')
      end

      it 'removes all other imports' do
        Import.create(nomis_exports: [nomis_export])
        ImportOffenders.call(import)
        expect(Import.count).to be 1
      end
    end

    context 'when failing' do
      let(:nomis_export) { fixture_file_upload('files/invalid_data.csv', 'text/csv') }

      it 'marks the import failed' do
        ImportOffenders.call(import)
        expect(import.status).to eq('failed')
      end

      it 'saves the errors' do
        offenders_with_errors = [
          {
            noms_id: '',
            nomis_offender_id: 1_056_827,
            date_of_birth: '1970/01/30 00:00:00',
            given_name_1: 'LARRY',
            given_name_2: 'MARK',
            given_name_3: 'JOE',
            surname: 'LATITUDE',
            title: 'MR',
            gender: 'M',
            pnc_number: '05/103329A',
            nationality_code: 'BRIT',
            ethnicity_code: 'W1',
            cro_number: '309129/05R',
            establishment_code: 'LEI',
            working_name: 'Working Name'
          },
          {
            noms_id: 'A1234BC',
            nomis_offender_id: 1_055_829,
            date_of_birth: '1980/02/20 00:00:00',
            given_name_1: '',
            given_name_2: 'LUKE',
            given_name_3: 'FRANK',
            surname: 'DOE',
            title: 'MR',
            gender: 'M',
            pnc_number: '07/3862805R',
            nationality_code: 'BRIT',
            ethnicity_code: 'B1',
            cro_number: '339223/02H',
            establishment_code: 'LEI',
            working_name: 'Alias'
          },
          {
            noms_id: 'A1234BU',
            nomis_offender_id: 1_055_847,
            date_of_birth: '1990/03/10 00:00:00',
            given_name_1: 'BOB',
            given_name_2: 'ROBERT',
            given_name_3: '',
            surname: 'DYLAN',
            title: 'MR',
            gender: '',
            pnc_number: '04/837105K',
            nationality_code: 'BRIT',
            ethnicity_code: 'A1',
            cro_number: '378468/01T',
            establishment_code: 'BXI',
            working_name: 'Working Name'
          }
        ]

        ImportOffenders.call(import)

        error_header = "There were some errors in file invalid_data.csv\n"
        error_log = error_header + offenders_with_errors.join("\n")
        expect(import.error_log).to eq(error_log)
      end

      it 'sends an email' do
        expect { ImportOffenders.call(import) }
          .to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end
  end
end
