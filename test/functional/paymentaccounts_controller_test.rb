require 'test_helper'

class PaymentaccountsControllerTest < ActionController::TestCase
  setup do
    @paymentaccount = paymentaccounts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:paymentaccounts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create paymentaccount" do
    assert_difference('Paymentaccount.count') do
      post :create, paymentaccount: { agreement: @paymentaccount.agreement, user_id: @paymentaccount.user_id, wepay_access_token: @paymentaccount.wepay_access_token, wepay_account_id: @paymentaccount.wepay_account_id }
    end

    assert_redirected_to paymentaccount_path(assigns(:paymentaccount))
  end

  test "should show paymentaccount" do
    get :show, id: @paymentaccount
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @paymentaccount
    assert_response :success
  end

  test "should update paymentaccount" do
    put :update, id: @paymentaccount, paymentaccount: { agreement: @paymentaccount.agreement, user_id: @paymentaccount.user_id, wepay_access_token: @paymentaccount.wepay_access_token, wepay_account_id: @paymentaccount.wepay_account_id }
    assert_redirected_to paymentaccount_path(assigns(:paymentaccount))
  end

  test "should destroy paymentaccount" do
    assert_difference('Paymentaccount.count', -1) do
      delete :destroy, id: @paymentaccount
    end

    assert_redirected_to paymentaccounts_path
  end
end
