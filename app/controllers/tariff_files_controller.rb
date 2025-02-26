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
    if tariff_file_params[:files].present? && tariff_file_params[:tariff_id].present?
      tariff_file_params[:files].each do |file|
        @tariff_file = TariffFile.new(file: file, tariff_id: tariff_file_params[:tariff_id])
        unless @tariff_file.save
          render :new, status: :unprocessable_entity and return
        end
      end
      redirect_to tariff_files_path, notice: 'Файлы успешно загружены.'
    else
      @tariff_file = TariffFile.new(tariff_file_params)
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
