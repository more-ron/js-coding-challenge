require 'test_helper'

class RootControllerTest < ActionDispatch::IntegrationTest
  test "root loading" do
    get root_path
    assert_response :success
  end
end
