module ParseOffenders
  module_function

  def call(data)
    @import_time = Time.now

    errors = []

    SmarterCSV.process(data, chunk_size: 1000, key_mapping: keys_mapping, remove_empty_values: false) do |chunk|
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

      # Original implementation commented out - reliant on NOMIS_OFFENDER_ID
      # being present in extract.

      # identity = offender.identities.find_or_initialize_by(nomis_offender_id: row[:nomis_offender_id])
      # errors << row unless identity.update(identity_attrs(row))
      #
      # set_current_offender(offender, identity, row)


      # Interim implementation. Destroys all identities on an offender which
      # were present prior to the start of the import then recreates from extract.

      offender.identities.where('identities.created_at < ?', @import_time).destroy_all

      identity = offender.identities.new(nomis_offender_id: row[:nomis_offender_id])
      errors << row unless identity.update(identity_attrs(row))

      set_current_offender(offender, identity, row)
    end

    def keys_mapping
      {
        noms_number: :noms_id,
        nomis_offender_id: :nomis_offender_id,
        salutation: :title,
        gender_code: :gender,
        pnc_id: :pnc_number,
        criminal_records_office_number: :cro_number
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
