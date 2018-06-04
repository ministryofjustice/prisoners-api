class AddOffendersFilesToImports < ActiveRecord::Migration[5.0]
  def change
    remove_column :imports, :identities_file
    remove_column :imports, :offenders_file
    add_column :imports, :nomis_exports, :json
    add_column :imports, :report_log, :text
  end
end
