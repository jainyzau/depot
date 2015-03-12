class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authorize
  before_action :set_i18n_locale_from_params

  protected
    # copied from course hints since I get to do one urgent thing.
    def authorize
        return if User.count.zero?

        if request.format == Mime::HTML
          user = User.find_by(id: session[:user_id])
        else
          user = authenticate_or_request_with_http_basic do |u, p|
            User.find_by_name(u).try(:authenticate, p)
          end
        end

        redirect_to login_url, notice: "Please log in" unless user
    end

    def set_i18n_locale_from_params
    	if params[:locale]
		if I18n.available_locales.map(&:to_s).include?(params[:locale])
			I18n.locale = params[:locale]
		else
			flash.now[:notice] = "#{params[:locale]} translation not available"
			logger.error flash.now[:notice]
		end
	end
    end

    def default_url_options
    	{locale: I18n.locale}
    end
end
