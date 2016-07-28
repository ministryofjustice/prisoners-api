class ImportsController < ApplicationController
  before_action :set_import, only: [:show]

  def index
    @imports = Import.order(created_at: :desc)
  end

  def new
    @import = Import.new
  end

  def show
  end

  def create
    result = ImportPrisoners.new(import_params).call
    @import = result.import

    if result.success?
      redirect_to @import
    else
      render :new
    end
  end

  private

  def set_import
    @import = Import.find(params[:id])
  end

  def import_params
    params.require(:import).permit(:file)
  end
end
