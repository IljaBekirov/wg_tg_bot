# frozen_string_literal: true

class SessionsController < ApplicationController
  def new; end

  def create
    admin = Admin.find_by(email: params[:email].downcase)
    if admin&.authenticate(params[:password])
      session[:admin_id] = admin.id
      redirect_to root_path, notice: 'Вы успешно вошли в систему'
    else
      flash.now[:alert] = 'Неверный email или пароль'
      render 'new'
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to root_path, notice: 'Вы вышли из системы'
  end
end
