class CopyPriceToLineItems < ActiveRecord::Migration
  def up
    LineItem.all.each do |item|
        product = Product.find(item.product.id)
        item.price = product.price
        item.save!
    end
  end

  def down
    LineItem.all.each do |item|
        item.price = nil
        item.save!
    end
  end
end
