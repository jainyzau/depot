module ApplicationHelper
    def hide_div_if(condition, attributes, &block)
        if condition
            attributes["style"] = "display: none"
        end
        content_tag("div", attributes, &block)
    end

    def price_localize(price)
      # should fetch from db or some other sources.
      usd2cny = 6.2612
      usd2eur = 0.9423

      if I18n.locale.to_s == 'zh'
        price *= usd2cny
      elsif I18n.locale.to_s == 'es'
        price *= usd2eur
      end
        price
    end
end
