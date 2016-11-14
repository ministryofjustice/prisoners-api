class CreateAliases < ActiveRecord::Migration
  def change
    create_table :aliases do |t|
      t.uuid :prisoner_id, index: true, foreign_key: true

      t.string :title
      t.string :given_name, index: true
      t.string :middle_names
      t.string :surname, index: true
      t.string :suffix
      t.date   :date_of_birth
      t.string :gender
      t.string :pnc_number, index: true
      t.string :cro_number, index: true
    end
  end
end
