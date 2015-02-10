require 'test_helper'

class CartTest < ActiveSupport::TestCase
  fixtures :products

  test "add unique product" do
    cart = Cart.new

    assert_difference('cart.line_items.size', 1) do
        cart.add_product products(:ruby).id
    end
  end

  test "add duplicate product" do
    cart = carts(:one)
    product_id = products(:ruby).id
    
    assert_difference('cart.line_items.size', 1) do
        count = 5
        count.times { cart.add_product(product_id).save! }
    end
  end
end
