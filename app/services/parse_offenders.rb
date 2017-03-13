module ParseOffenders
  class ParsingError < StandardError; end

  module_function

  def call(data)
    require 'csv'

    csv = CSV.parse(data, headers: true)

    csv.each_with_index do |row, line_number|
      parse_row(row, line_number + 1)
    end
  end

  class << self
    private

    def parse_row(row, line_number)
      offender = update_or_create_offender(row)
      update_or_create_identity(offender, row)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound, ArgumentError
      raise(ParsingError, "Error parsing line #{line_number}")
    end

    def update_or_create_offender(row)
      offender = Offender.find_by(noms_id: row['NOMS_NUMBER'])
      if offender
        offender.update!(offender_attributes_from(row))
        offender
      else
        Offender.create!(offender_attributes_from(row))
      end
    end

    def update_or_create_identity(offender, row)
      identity = offender.identities.where(noms_offender_id: row['NOMIS_OFFENDER_ID']).first
      if identity
        identity.update!(identity_attributes_from(row))
      else
        identity = offender.identities.create!(identity_attributes_from(row))
      end
      offender.update!(current_identity: identity) if row['WORKING_NAME'] == 'Y'
      identity
    end

    def offender_attributes_from(row)
      {
        noms_id: row['NOMS_NUMBER'],
        nationality_code: row['NATIONALITY_CODE'],
        establishment_code: row['ESTABLISHMENT_CODE']
      }
    end

    def identity_attributes_from(row)
      {
        noms_offender_id: row['NOMIS_OFFENDER_ID'],
        given_name_1: row['GIVEN_NAME_1'], given_name_2: row['GIVEN_NAME_2'], given_name_3: row['GIVEN_NAME_3'],
        surname: row['SURNAME'],
        title: row['SALUTATION'],
        date_of_birth: Date.parse(row['DATE_OF_BIRTH']),
        gender: row['GENDER_CODE'], ethnicity_code: row['ETHNICITY_CODE'],
        pnc_number: row['PNC_ID'], cro_number: row['CRIMINAL_RECORDS_OFFICE_NUMBER'],
        status: 'active'
      }
    end
  end
end