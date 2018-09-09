# NOTE: Product#data is only designed for display. Even though #data is saved as binary JSON that
#       allows indexing it's better to have a dedicated column for data filters. If the need for an
#       element on #data to be queryable arises move that piece of data to an indexed column.
#
#       Product#last_updated_at is different to Rails' Product#updated_at. It indicates when
#       Product#raw_html was last updated and not the record.
class Product < ApplicationRecord
  validates :asin, uniqueness: true, presence: true

  # @return [String]
  def name
    data['name']
  end

  # @return [String]
  def main_image
    data['main_image']
  end

  # @return [String]
  def main_category
    data['main_category']
  end

  # @return [Array<Hash>]
  def rankings
    data['rankings']
  end

  # @return [String]
  def dimensions
    detail_named 'Product Dimensions'
  end

  # If stale its time to refresh the data.
  # @return [TrueClass,FalseClass]
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
