# frozen_string_literal: true

class TariffFilesController < ApplicationController
  before_action :require_admin

  def index
    render json: TariffFile.all
  end

  def new
    @tariff_file = TariffFile.new
  end

  def create
    @tariff_file = TariffFile.new(tariff_file_params)

    if @tariff_file.save
      redirect_to new_tariff_file_path, notice: 'Файл успешно загружен.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def tariff_file_params
    params.require(:tariff_file).permit(:file, :tariff_id)
  end
end
