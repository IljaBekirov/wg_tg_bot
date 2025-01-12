# frozen_string_literal: true

class TariffsController < ApplicationController
  def index
    render json: Tariff.all
  end
end
