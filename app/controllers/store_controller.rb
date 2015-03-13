class StoreController < ApplicationController
  include VisitCount
  include CurrentCart
  before_action :set_counter, only: [:index]
  before_action :set_cart, only: [:index]
  skip_before_action :authorize

  def index
    if params[:set_locale]
      redirect_to store_url(locale: params[:set_locale])
    else
      @products = Product.order(:title)
    end
  end
end
