# frozen_string_literal: true

class TariffsController < ApplicationController
  def index
    render json: Tariff.all
  end

  def new
    @tariff = Tariff.new
  end

  def create
    @tariff = Tariff.new(tariff_params)

    if @tariff.save
      redirect_to new_tariff_path, notice: 'Тариф успешно создан.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def tariff_params
    params.require(:tariff).permit(:duration, :price, :description)
  end
end
