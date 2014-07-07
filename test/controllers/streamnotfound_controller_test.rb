require 'test_helper'

class StreamnotfoundControllerTest < ActionController::TestCase
  test "should get pagedoesntexist" do
    get :pagedoesntexist
    assert_response :success
  end

end
