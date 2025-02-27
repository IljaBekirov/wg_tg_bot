# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :require_admin
  before_action :set_order, only: :show

  def index
    @orders = Order.all.paginate(page: params[:page], per_page: 10)
  end

  def show; end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
