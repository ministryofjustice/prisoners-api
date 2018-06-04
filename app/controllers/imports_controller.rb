class ImportsController < ApplicationController
  def new
    @last_import = Import.last
    @import = Import.new
  end

  def create
    @last_import = Import.last
    @import = Import.new(import_params)
    if @import.save
      ProcessImportJob.perform_later @import
      # ImportOffenders.call(@import)
      redirect_to new_import_path
    else
      render :new
    end
  end

  def errors_log
    send_data Import.last.error_log, type: 'text', disposition: 'inline'
  end

  private

  def import_params
    params.require(:import).permit(nomis_exports: [])
  end
end
