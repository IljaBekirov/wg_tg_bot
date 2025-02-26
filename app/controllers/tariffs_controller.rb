# frozen_string_literal: true

class TariffsController < ApplicationController
  before_action :require_admin
  before_action :set_tariff, only: %i[edit update destroy]

  def index
    @tariffs = Tariff.all
  end

  def new
    @tariff = Tariff.new
  end

  def create
    @tariff = Tariff.new(tariff_params)

    if @tariff.save
      redirect_to tariffs_path, notice: 'Тариф успешно создан.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @tariff.update(tariff_params)
      redirect_to tariffs_path, notice: 'Тариф успешно обновлен.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tariff.destroy
    redirect_to tariffs_path, notice: 'Тариф успешно удален.'
  end

  private

  def set_tariff
    @tariff = Tariff.find(params[:id])
  end

  def tariff_params
    params.require(:tariff).permit(:duration, :price, :description)
  end
end
