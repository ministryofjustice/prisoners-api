module ParseOffenders
  module_function

  def call(file)
    errors = []

    data = Roo::Spreadsheet.open(file, extension: :xls)
    data.each_with_pagename do |_name, sheet|
      sheet.each(keys_mapping) do |row|
        next if row[:noms_id] == 'NOMS_NUMBER'

        begin
          parse_row(row, errors)
        rescue
          errors << row
        end
      end
    end

    errors
  end

  class << self
    private

    def parse_row(row, errors)
      errors << row && return if row[:noms_id].blank?

      offender = Offender.find_or_create_by(noms_id: row[:noms_id])
      offender.update(offender_attrs(row))

      identity = offender.identities.find_or_initialize_by(nomis_offender_id: row[:nomis_offender_id])
      errors << row unless identity.update(identity_attrs(row))

      set_current_offender(offender, identity, row)
    end

    def keys_mapping
      {
        noms_id: 'NOMS_NUMBER',
        nomis_offender_id: 'NOMIS_OFFENDER_ID',
        date_of_birth: 'DATE_OF_BIRTH',
        given_name_1: 'GIVEN_NAME_1',
        given_name_2: 'GIVEN_NAME_2',
        given_name_3: 'GIVEN_NAME_3',
        surname: 'SURNAME',
        title: 'SALUTATION',
        gender: 'GENDER_CODE',
        pnc_number: 'PNC_ID',
        nationality_code: 'NATIONALITY_CODE',
        cro_number: 'CRIMINAL_RECORDS_OFFICE_NUMBER',
        establishment_code: 'ESTABLISHMENT_CODE',
        ethnicity_code: 'ETHNICITY_CODE',
        working_name: 'WORKING_NAME'
      }
    end

    def offender_attrs(row)
      row.slice(:noms_id, :establishment_code, :nationality_code)
    end

    def identity_attrs(row)
      row.slice(:date_of_birth, :given_name_1, :given_name_2, :given_name_3, :surname,
                :title, :gender, :pnc_number, :cro_number, :nomis_offender_id, :ethnicity_code)
         .merge(status: 'active')
    end

    def set_current_offender(offender, identity, row)
      offender.update(current_identity: identity) if identity.persisted? && row[:working_name] == 'Y'
    end
  end
end
