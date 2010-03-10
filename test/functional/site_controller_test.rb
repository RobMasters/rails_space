require 'test_helper'

class SiteControllerTest < ActionController::TestCase
  
  def test_index
    get :index
    title = assigns(:title)
    assert_equal 'Welcome to RailsSpace!', title
    assert_response :success
    assert_template 'index'
  end
  
  def test_about
    get :about
    title = assigns(:title)
    assert_equal 'About RailsSpace', title
    assert_response :success
    assert_template 'about'
  end

  def test_help
    get :help
    title = assigns(:title)
    assert_equal 'RailsSpace Help', title
    assert_response :success
    assert_template 'help'
  end
  
  # Test the navigation menu before login
  test "navigation not logged in" do
    get :index
    assert_select "a[href=?]", '/user/register', :text => /Register/
    assert_select "a[href=?]", '/user/login', :text => /Login/
    # Test link_to_unless_current
    assert_select "a[href=?]", '/', :text => /Home/, :count => 0
  end
  
end
