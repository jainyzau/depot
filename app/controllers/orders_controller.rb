class EmailAddressError < Exception
end

class OrdersController < ApplicationController
  include CurrentCart
  before_action :set_cart, only: [:new, :create]
  before_action :set_order, only: [:show, :edit, :update, :destroy, :ship, :email_notification_error]
  rescue_from EmailAddressError, with: :email_notification_error
  skip_before_action :authorize, only: [:new, :create]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  def ship
    @order.ship_date = Time.now
    @order.save!
    if @order.email.match /^\w+([-\+.\w]+)*@\w+*([\.\w]+*)$/
        OrderNotifier.shipped(@order).deliver
    else
        raise EmailAddressError
    end
    redirect_to orders_url, notice: "Order #{@order.id} is shipped." 
  end

  # GET /orders/new
  def new
    if @cart.line_items.empty?
        redirect_to store_url, notice: I18n.t('.cart_is_empty')
        return
    end

    @checkout_page = true
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    if @cart.line_items.empty?
        redirect_to store_url, notice: I18n.t('.cart_is_empty') 
        return
    end

    @order = Order.new(order_params)
    @order.add_line_items_from_cart @cart

    respond_to do |format|
      if @order.save
        Cart.destroy session[:cart_id]
        session[:cart_id] = nil
        if @order.email.match /^\w+([-\+.\w]+)*@\w+*([\.\w]+*)$/
            OrderNotifier.received(@order).deliver
        else
            raise EmailAddressError
        end

        format.html { redirect_to store_url, notice: I18n.t('.create_order_thanks') }
        format.json { render action: 'show', status: :created, location: @order }
      else
        format.html { render action: 'new' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:name, :address, :email, :pay_type_id)
    end

    def email_notification_error
        OrderNotifier.notify_admin_email_error(@order).deliver
        redirect_to store_url, notice: 'Failed to send order confirmation email'
    end
end
