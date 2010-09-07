require 'test_helper'

class ExcelUploadsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:excel_uploads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create excel_upload" do
    assert_difference('ExcelUpload.count') do
      post :create, :excel_upload => { }
    end

    assert_redirected_to excel_upload_path(assigns(:excel_upload))
  end

  test "should show excel_upload" do
    get :show, :id => excel_uploads(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => excel_uploads(:one).to_param
    assert_response :success
  end

  test "should update excel_upload" do
    put :update, :id => excel_uploads(:one).to_param, :excel_upload => { }
    assert_redirected_to excel_upload_path(assigns(:excel_upload))
  end

  test "should destroy excel_upload" do
    assert_difference('ExcelUpload.count', -1) do
      delete :destroy, :id => excel_uploads(:one).to_param
    end

    assert_redirected_to excel_uploads_path
  end
end
