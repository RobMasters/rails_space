require 'test_helper'

class UserControllerTest < ActionController::TestCase
  include ApplicationHelper
  
  def setup
    # This user is initially valid, but we may change its attributes
    @valid_user = users(:valid_user)
  end
	
	# Make sure the registration page responds with the proper form
  test "registration page" do
		get :register
		title = assigns(:title)
		assert_equal 'Register', title
		assert_response :success
		assert_template 'register'
		
		# Test the form and all its tags
		assert_tag 'form', :attributes => { :action => '/user/register', :method => 'post' }
		assert_tag 'input', :attributes => {
			:name => 'user[screen_name]', 
			:type => 'text', 
			:size => User::SCREEN_NAME_SIZE, 
			:maxlength => User::SCREEN_NAME_MAX_LENGTH
		}
		assert_tag 'input', 
		            :attributes => {	:name => 'user[email]', 
			                            :type => 'text', 
                                  :size => User::EMAIL_SIZE, 
                                  :maxlength => User::EMAIL_MAX_LENGTH }
		assert_tag 'input', 
		            :attributes => {  :name => 'user[password]', 
			                            :type => 'password', 
			                            :size => User::PASSWORD_SIZE, 
			                            :maxlength => User::PASSWORD_MAX_LENGTH }
		assert_tag 'input', :attributes => { :type => 'submit', :value => 'Register!' }
	end
	
	# Test a valid registration
  test "registration success" do
		post :register, :user => {
			:screen_name => 'new_screen_name', 
			:email => 'valid@example.com', 
			:password => 'long_enough_password'
		}
		
		# Test assignment of user
		user = assigns(:user)
		assert_not_nil user
		
		# Test new user in database
		new_user = User.find_by_screen_name_and_password(user.screen_name, user.password)
		assert_equal new_user, user
		
		# Test flash and redirect
		assert_equal "User #{new_user.screen_name} created!", flash[:notice]
		assert_redirected_to :action => 'index'
		
		# Make sure the user is logged in properly
		assert logged_in?
		assert_equal session[:user_id], user.id
	end
	
	# Make sure the login page works and has the right fields.
  test "login page" do
    get :login
    title = assigns(:title)
    assert_equal "Log in to RailsSpace", title
    assert_response :success
    assert_template "login"
    assert_tag "form", :attributes => { :action => "/user/login", 
                                        :method => "post" }
    assert_tag "input",
               :attributes => { :name => "user[screen_name]",
                                :type => "text", 
                                :size => User::SCREEN_NAME_SIZE,
                                :maxlength => User::SCREEN_NAME_MAX_LENGTH }
    assert_tag "input", 
               :attributes => { :name => "user[password]",
                                :type => "password",
                                :size => User::PASSWORD_SIZE,
                                :maxlength => User::PASSWORD_MAX_LENGTH }
    assert_tag "input", :attributes => { :type => "submit",
                                         :value => "Login!" }
  end   
  
  # Test a valid login
  test "login success" do
    try_to_login @valid_user
    assert logged_in?
    assert_equal @valid_user.id, session[:user_id]
    assert_equal "User #{@valid_user.screen_name} logged in!", flash[:notice]
    assert_redirected_to :action => 'index'
  end
  
  # Test a login with invalid screen name.
  test "login failure with nonexistent screen name" do
    invalid_user = @valid_user
    invalid_user.screen_name = "no such user"
    try_to_login invalid_user
    assert_template "login"
    assert_equal "Invalid screen name/password combination", flash[:notice]
    # Make sure screen_name will be redisplayed, but not the password.
    user = assigns(:user)
    assert_equal invalid_user.screen_name, user.screen_name
    assert_nil user.password
  end

  # Test a login with invalid password.
  test "login failure with wrong password" do
    invalid_user = @valid_user
    # Construct an invalid password.
    invalid_user.password += "baz"
    try_to_login invalid_user
    assert_template "login"
    assert_equal "Invalid screen name/password combination", flash[:notice]
    # Make sure screen_name will be redisplayed, but not the password.
    user = assigns(:user)
    assert_equal invalid_user.screen_name, user.screen_name
    assert_nil user.password
  end
  
  # Test the logout function
  test "logout" do
    try_to_login @valid_user
    assert_not_nil session[:user_id]
    get :logout
    assert_response :redirect
    assert_redirected_to site_path
    assert_equal "Logged out", flash[:notice]
    assert !logged_in?
  end
  
  # Test the navigation menu after login
  test "navigation logged in" do
    authorize @valid_user
    get :index
    assert_select "a[href=?]", "/user/logout", :text => /Logout/
    assert_select "a[href=?]", "/user/login", :text => /Login/, :count => 0
    assert_select "a[href=?]", "/user/register", :text => /Register/, :count => 0
  end
  
  # Test index page for unauthorized user
  test "index unauthorized" do
    # Make sure the before filter is working
    get :index
    assert_response :redirect
    assert_redirected_to :action => 'login'
    assert_equal "Please log in first", flash[:notice]
  end
  
  # Test index page for authorized user
  test "index authorized" do
    authorize @valid_user
    get :index
    assert_response :success
    assert_template 'index'
  end
  
  # Test forward back to protected page after login
  test "login friendly url forwarding" do
    user = {  :screen_name => @valid_user.screen_name, 
              :password => @valid_user.password }
    friendly_url_forwarding_aux(:login, :index, user)
  end
  
  # Test forward back to protected page after register
  test "register friendly url forwarding" do
   user = {  :screen_name => "new_screen_name", 
             :email => "valid@example.com", 
             :password => "long_enough_password" }
    friendly_url_forwarding_aux(:register, :index, user)
  end
	
	
	private
	
	# Try to log a user in using the login action
	def try_to_login(user)
	  post :login, :user => { :screen_name => user.screen_name, 
	                          :password => user.password }
	end
	
	# Authorize a user
	def authorize(user)
	 @request.session[:user_id] = user.id
	end
	
	def friendly_url_forwarding_aux(test_page, protected_page, user)
	  get protected_page
    assert_response :redirect
    assert_redirected_to :action => 'login'
    post test_page, :user => user
    assert_response :redirect
    assert_redirected_to :action => protected_page
    # Make sure the forwarding url has been cleared`
    assert_nil session[:protected_page]
	end
	
end
