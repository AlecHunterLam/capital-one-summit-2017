require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get search_home_url
    assert_response :success
  end

  test "should get show" do
    get search_show_url
    assert_response :success
  end

end
