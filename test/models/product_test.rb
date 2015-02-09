require 'test_helper'

class ProductTest < ActiveSupport::TestCase
    fixtures :products
  # test "the truth" do
  #   assert true
  # end
  test "title should has 10 or more characters" do
      product = Product.new
      product.title = "my book1"
      assert product.invalid?
      assert_equal ["at least 10 characters."], product.errors[:title]
  end

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price should be positive" do
    product = Product.new 
    product.title = "MyBook 1 Edition 1"
    product.description = "This is MyBook 1"
    product.image_url = "test.png"

    product.price = -1
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(url)
    product = Product.new
    product.title = "my book1 edtion 1"
    product.description = "desc for my book1"
    product.price = 9.9
    product.image_url = url
    product
  end

  test "image url" do
    ok = %w{fred.gif fred.jpg fred.png RED.JPG FRED.Jpg http://a.xyz.com/img/2015/xxx.gif}
    bad = %w{ fred.doc fred.gif/more fred.gif.more}
    ok.each do |url|
        assert new_product(url).valid?, "#{url} should be valid"
    end
    bad.each do |url|
        assert new_product(url).invalid?, "#{url} shouldn't be valid"
    end
  end

  test "use fixture" do
    product = Product.new
    product.title = products(:ruby).title
    product.description = products(:ruby).description
    product.price = products(:ruby).price
    product.image_url = products(:ruby).image_url

    assert product.invalid?
  #  assert_equal ["has already been taken"], product.errors[:title]
    assert_equal [I18n.translate('errors.messages.taken')], product.errors[:title]
  end
end
