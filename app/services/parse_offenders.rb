module ParseOffenders
  KEYS_MAPPING = {
    noms_number: :noms_id,
    alias_offender_id: :nomis_offender_id,
    alias_date_of_birth: :date_of_birth,
    alias_given_name_1: :given_name_1,
    alias_given_name_2: :given_name_2,
    alias_given_name_3: :given_name_3,
    alias_surname: :surname,
    salutation: :title,
    alias_gender: :gender,
    pnc_id: :pnc_number,
    nationality_code: :nationality_code,
    ethnic_code: :ethnicity_code,
    ethnic_description: nil,
    sexual_orientation_code: nil,
    sexual_orientation_description: nil,
    criminal_records_office_number: :cro_number,
    associated_establishment_code: :establishment_code,
    alias_or_working_name?: :working_name
  }.freeze

  module_function

  def call(data)
    errors = []

    SmarterCSV.process(data, chunk_size: 1000, key_mapping: KEYS_MAPPING, remove_empty_values: false) do |chunk|
      chunk.each { |row| parse_row(row, errors) }
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

    def offender_attrs(row)
      row.slice(:noms_id, :establishment_code, :nationality_code)
    end

    def identity_attrs(row)
      row.slice(:date_of_birth, :given_name_1, :given_name_2, :given_name_3, :surname,
                :title, :gender, :pnc_number, :cro_number, :nomis_offender_id, :ethnicity_code)
         .merge(status: 'active')
    end

    def set_current_offender(offender, identity, row)
      offender.update(current_identity: identity) if identity.persisted? && row[:working_name] == 'Working Name'
    end
  end
end
