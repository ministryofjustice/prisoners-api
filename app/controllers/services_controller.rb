class ServicesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authorise_admin!
  before_action :set_service, only: [:show, :edit, :update, :destroy]

  def index
    @services = Doorkeeper::Application.order(name: :asc)
  end

  def show; end

  def new
    @service = Doorkeeper::Application.new
  end

  def edit; end

  def create
    @service = Doorkeeper::Application.new(service_params)

    if @service.save
      redirect_to services_url, notice: 'Service added'
    else
      render :new
    end
  end

  def update
    if @service.update(service_params)
      redirect_to services_url, notice: 'Service updated'
    else
      render :edit
    end
  end

  def destroy
    @service.destroy
    redirect_to services_url, notice: 'Service removed'
  end

  private

  def set_service
    @service = Doorkeeper::Application.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:name, :redirect_uri, :scopes)
  end
end
