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
    assert_equal 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7', product.main_image

    assert_equal [
                   { "rank" => "6", "category" => "Baby" },
                   { "rank" => "1", "category" => "Baby > Baby Care > Health" },
                   { "rank" => "2", "category" => "Baby > Baby Care > Pacifiers, Teethers & Teething Relief > Teethers" }
                 ],
                 product.rankings
  end
end
