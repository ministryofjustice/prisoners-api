class ChangeIdentitiesNomisOffenderId < ActiveRecord::Migration[5.0]
  def change
    change_column :identities, :nomis_offender_id, 'integer USING CAST(nomis_offender_id AS float)'
  end
end
