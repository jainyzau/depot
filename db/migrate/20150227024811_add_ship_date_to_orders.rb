class AddShipDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :ship_date, :timestamp
  end
end
