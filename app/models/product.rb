class Product < ActiveRecord::Base
    has_many :line_items
    before_destroy :ensure_no_referenced_by_any_line_item
    validates :title, :description, :image_url, presence: true
    validates :price, numericality: {greater_than_or_equal_to: 0.01}
    validates :title, uniqueness: true, length: { minimum: 10, message: 'at least 10 characters.'}
    validates :image_url, allow_blank: true, format: {
        with: /\.(gif|jpg|png)\Z/i,
        message: 'must be a URL for GIF, JPG or PNG image.'
    }

    # support caching.
    def self.latest
        Product.order(:updated_at).last
    end

  private
    def ensure_no_referenced_by_any_line_item
        if line_items.empty?
            return true
        else
            errors.add :base, 'Line items present'
            return false
        end
    end
    
end
