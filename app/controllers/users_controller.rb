# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: :show

  def index
    @users = User.all.order(:id)
  end

  def show; end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
