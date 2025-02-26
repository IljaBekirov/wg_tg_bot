module SessionsHelper
  def current_admin
    @current_admin ||= Admin.find_by(id: session[:admin_id]) if session[:admin_id]
  end

  def logged_in?
    !current_admin.nil?
  end

  def require_admin
    return if logged_in?

    flash[:alert] = 'Пожалуйста, войдите в систему'
    redirect_to login_path
  end
end
