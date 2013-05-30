class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale
  before_filter :set_password

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def set_password
    return unless current_user && current_user.encrypted_password.blank?
    redirect_to change_password_user_path(current_user), notice: t('flash.notice.set_your_password_now')
  end

  def default_url_options(options={})
    #logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end

  def after_sign_in_path_for(resource)
    "/#{I18n.locale}"
  end
end
