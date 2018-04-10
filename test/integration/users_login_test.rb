require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:tester)
  end
  
  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }  # failed login
    assert_template 'sessions/new'
    assert_not flash.empty? # assert that there is a flash message
    get root_path # go to any other page
    assert flash.empty? # assert that there is no flash message
  end
  
  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email,
                                          password: "password" } }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0 # there are no login links
    assert_select "a[href=?]", logout_path  # there is a logout link
    assert_select "a[href=?]", user_path(@user)  # we are on the @user profile page
    # end login test
    # begin logout test
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    delete logout_path  # simulate user clicking logout in a second window
    follow_redirect!
    assert_select "a[href=?]", login_path  # there is a login link
    assert_select "a[href=?]", logout_path,      count: 0  # there is no logout link
    assert_select "a[href=?]", user_path(@user), count: 0  # not showing profile page
  end
  
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies['remember_token']
  end
  
  test "login without remembering" do
    # "we want to be remembered"
    log_in_as(@user, remember_me: '1')
    # "changed my mind! don't remember me!"
    log_in_as(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
  
end
