class PayType < ActiveRecord::Base
    has_many :order

    def name_localize
      I18n.t("PayTypes.paytype_#{id}")
    end
end
