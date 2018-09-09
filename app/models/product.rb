# Note: Product#data is only designed for display. If the need for an element on #data to be
#       queryable arises move that piece of data to an indexed column.
class Product < ApplicationRecord
  validates :asin, uniqueness: true, presence: true

  def name
    data['name']
  end

  def main_image
    data['main_image']
  end

  def main_category
    data['main_category']
  end

  def rankings
    data['rankings']
  end

  def dimensions
    detail_named 'Product Dimensions'
  end

  def stale?
    (last_updated_at || Time.at(0)) < 5.minutes.ago
  end

  private

  def detail_named(name)
    if data['product_details'].present?
      detail = data['product_details'].find { |item| item['label'] == name }
      detail['value'] if detail.present?
    end
  end
end
