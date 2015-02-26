class PayType < ActiveRecord::Base
    has_many :order
end
