# frozen_string_literal: true

class TariffFilesController < ApplicationController
  before_action :require_admin
  before_action :set_tariff_file, only: [:destroy]
  before_action :set_server_service, only: %i[create destroy]

  def index
    @tariff_files = TariffFile.all.order(:id)
      .paginate(page: params[:page], per_page: 10)
  end

  def new
    @tariff_file = TariffFile.new
  end

  def create
    creator = TariffFileCreator.new(@server_service, config_params)
    result = creator.create_configs

    if result.success?
      redirect_to tariff_files_path, notice: "Создано #{result.created_count} конфига(ов)"
    else
      Rails.logger.error("Ошибки при создании конфига(ов): #{result.errors.join(', ')}")
      redirect_to tariff_files_path,
        alert: "Создано #{result.created_count} конфига(ов), ошибки: #{result.errors.join(', ')}"
    end
  end

  def destroy
    response = @server_service.remove_client(@tariff_file.wg_uuid)
    if response.success?
      @tariff_file.destroy!
      redirect_to tariff_files_path, notice: 'Конфиг успешно удален'
    else
      Rails.logger.error("Не удалось удалить конфиг на wg-easy: #{@tariff_file.wg_uuid}")
      redirect_to tariff_files_path, alert: 'Не удалось удалить конфиг на wg-easy'
    end
  end

  private

  def set_tariff_file
    @tariff_file = TariffFile.find(params[:id])
  end

  def set_server_service
    @server_service = WireguardService.new(ENV['SERVICE_URL'], ENV['SERVICE_PASSWORD'])
    @server_service.login unless @server_service.logged_in?
  end

  def config_params
    params.require(:tariff_file).permit(:name, :quantity)
  end
end
