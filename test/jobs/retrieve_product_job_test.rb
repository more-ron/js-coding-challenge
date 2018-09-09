require 'test_helper'

class RetrieveProductJobTest < ActiveJob::TestCase
  test "the truth" do
    assert_difference -> { Product.count } do
      RetrieveProductJob.perform_now 'B002QYW8LW'
    end

    product = Product.last

    assert_equal 'B002QYW8LW', product.asin
    assert_equal 'Baby Banana Infant Training Toothbrush and Teether, Yellow', product.name
    assert_equal 'Baby', product.main_category
    assert_equal '4.3 x 0.4 x 7.9 inches', product.dimensions
    assert_equal 'https://images-na.ssl-images-amazon.com/images/I/316WpcHV%2BHL._SY300_QL70_.jpg', product.main_image

    assert_equal [
                   { "rank" => "6", "category" => "Baby" },
                   { "rank" => "1", "category" => "Baby > Baby Care > Health" },
                   { "rank" => "2", "category" => "Baby > Baby Care > Pacifiers, Teethers & Teething Relief > Teethers" }
                 ],
                 product.rankings
  end
end
