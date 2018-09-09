require 'test_helper'

class Api::V1::ProductsControllerTest < ActionDispatch::IntegrationTest
  test "showing product" do
    get api_v1_product_path(id: 'B002QYW8LW')

    assert_response :success

    assert_equal(
      {
        "asin" => "B002QYW8LW",
        "dimensions" => "4.3 x 0.4 x 7.9 inches",
        "main_category" => "Baby",
        "main_image" => "https://images-na.ssl-images-amazon.com/images/I/316WpcHV%2BHL._SY300_QL70_.jpg",
        "name" => "Baby Banana Infant Training Toothbrush and Teether, Yellow",
        "rankings" => [
          { "rank" => "6", "category" => "Baby" },
          { "rank" => "1", "category" => "Baby > Baby Care > Health" },
          { "rank" => "2", "category" => "Baby > Baby Care > Pacifiers, Teethers & Teething Relief > Teethers" }
        ]
      },
      response.parsed_body.except('last_updated_at')
    )
  end
end
