# frozen_string_literal: true

class TariffFilesController < ApplicationController
  before_action :require_admin
  before_action :set_tariff_file, only: [:destroy]

  def index
    @tariff_files = TariffFile.all
  end

  def new
    @tariff_file = TariffFile.new
  end

  def create
    result = TariffFiles::BulkUploadService.call(tariff_file_params)

    if result.success?
      redirect_to tariff_files_path, notice: 'Файлы успешно загружены.'
    else
      @tariff_file = result.tariff_file || TariffFile.new(tariff_file_params)
      flash.now[:alert] = result.error_message
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @tariff_file.destroy
    redirect_to tariff_files_path, notice: 'Файл успешно удален.'
  end

  private

  def set_tariff_file
    @tariff_file = TariffFile.find(params[:id])
  end

  def tariff_file_params
    params.require(:tariff_file).permit(:tariff_id, files: [])
  end
end
