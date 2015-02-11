class StoreController < ApplicationController
  include VisitCount
  include CurrentCart
  before_action :set_counter, only: [:index]
  before_action :set_cart, only: [:index]

  def index
    @products = Product.order(:title)
  end
end
