require 'test_helper'

class UserStoriesTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  #fixtures :products
  
  test "buying a product" do
    LineItem.delete_all
    Order.delete_all
    ruby_book = products(:ruby)

    get "/"
    assert_response :success
    assert_template "index"

    xml_http_request :post, '/line_items', product_id: ruby_book.id
    assert_response :success

    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    get "/orders/new"
    assert_response :success
    assert_template "new"

    post_via_redirect "/orders", 
                        order: {
                            name: "Dave Thomas",
                            address: "123 The Street",
                            email:  "dave@example.com",
                            pay_type_id: pay_types(:one).id
                            }
    assert_response :success
    assert_template "index"
    cart = Cart.find(session[:cart_id])
    assert_equal 0, cart.line_items.size

    orders = Order.all
    assert_equal 1, orders.size
    order = orders[0]

    assert_equal "Dave Thomas", order.name
    assert_equal "123 The Street", order.address
    assert_equal "dave@example.com", order.email
    assert_equal pay_types(:one).name, order.pay_type.name

    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]
    assert_equal ruby_book, line_item.product

    mail = ActionMailer::Base.deliveries.last
    assert_equal ["dave@example.com"], mail.to
    assert_equal 'admin@depot.com', mail[:from].value
    assert_equal 'Pragmatic Store Order Confirmation', mail.subject

    # test shipping order
    get_via_redirect "/orders/ship/#{order.id}"
    assert_response :success
    assert_template "index"

    mail = ActionMailer::Base.deliveries.last
    assert_equal ["dave@example.com"], mail.to
    assert_equal 'admin@depot.com', mail[:from].value
    assert_equal 'Pragmatic Store Order Shipped', mail.subject

    order = Order.all[0]
    assert !order.ship_date.nil?
  end

  test "buying a product with incorrect email address" do
    LineItem.delete_all
    Order.delete_all
    ruby_book = products(:ruby)

    get "/"
    assert_response :success
    assert_template "index"

    xml_http_request :post, '/line_items', product_id: ruby_book.id
    assert_response :success

    cart = Cart.find(session[:cart_id])
    assert_equal 1, cart.line_items.size
    assert_equal ruby_book, cart.line_items[0].product

    get "/orders/new"
    assert_response :success
    assert_template "new"

    post_via_redirect "/orders", 
                        order: {
                            name: "Dave Thomas",
                            address: "123 The Street",
                            email:  "dave", # incorrect email address
                            pay_type_id: pay_types(:one).id
                            }
    assert_response :success
    assert_template "index"
    cart = Cart.find(session[:cart_id])
    assert_equal 0, cart.line_items.size

    orders = Order.all
    assert_equal 1, orders.size
    order = orders[0]

    assert_equal "Dave Thomas", order.name
    assert_equal "123 The Street", order.address
    assert_equal "dave", order.email
    assert_equal pay_types(:one).name, order.pay_type.name

    assert_equal 1, order.line_items.size
    line_item = order.line_items[0]
    assert_equal ruby_book, line_item.product

    # email error, send email to developer.
    mail = ActionMailer::Base.deliveries.last
    assert_equal ["haifeng.zhao@truepartner.cn"], mail.to
    assert_equal 'admin@depot.com', mail[:from].value
    assert_equal '[Depot][Error] Email Notification Failed', mail.subject
  end
end
