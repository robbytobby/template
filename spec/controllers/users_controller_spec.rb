require 'spec_helper'
include Warden::Test::Helpers

describe UsersController do

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { FactoryGirl.attributes_for(:user) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  login
  before(:each){ @other_user = FactoryGirl.create(:user) }

  describe "GET index" do
    it "assigns all users as @users" do
      get :index
      assigns(:users).should eq([@current_user, @other_user])
      response.should render_template 'users/index'
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      get :show, {:id => @other_user.to_param}
      assigns(:user).should eq(@other_user)
      response.should render_template 'users/show'
    end
  end

  describe "GET new" do
    it "assigns a new user as @user" do
      get :new, {}
      assigns(:user).should be_a_new(User)
      response.should render_template 'users/new'
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      get :edit, {:id => @other_user.to_param}
      assigns(:user).should eq(@other_user)
      response.should render_template 'users/edit'
    end
  end

  describe "Get change_password" do
    it "assigns the requested users as @user" do
      get :change_password, {id: @current_user.to_param}
      assigns(:user).should eq(@current_user)
      response.should render_template 'users/change_password'
    end

    it "redirect to welcom#index if trying to change another users password" do
      get :change_password, {id: @other_user.to_param}
      response.should redirect_to welcome_index_path
    end
  end

  describe "POST update_password" do
    it "updates the requested users password" do
      old_encrypted_password = @current_user.encrypted_password
      post :update_password, {:id => @current_user.to_param, :user => { password: '123456789', password_confirmation: '123456789' }}
      @current_user.reload.encrypted_password.should_not == old_encrypted_password
      response.should redirect_to welcome_index_path
    end

    it "re-renders change_password if confirmation does not match" do
      post :update_password, {:id => @current_user.to_param, :user => { password: '123456789', password_confirmation: 'abc' }}
      response.should render_template('change_password')
    end

    it "redirect to welcom#index if trying to update another users password" do
      old_encrypted_password = @other_user.encrypted_password
      post :update_password, {:id => @other_user.to_param, :user => { password: '123456789', password_confirmation: '123456789' }}
      response.should redirect_to welcome_index_path
      @other_user.reload.encrypted_password.should == old_encrypted_password
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new User" do
        expect {
          post :create, {:user => valid_attributes}
        }.to change(User, :count).by(1)
      end

      it "assigns a newly created user as @user" do
        post :create, {:user => valid_attributes}
        assigns(:user).should be_a(User)
        assigns(:user).should be_persisted
      end

      it "redirects to the created user" do
        post :create, {:user => valid_attributes}
        response.should redirect_to(User.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        post :create, {:user => {  }}
        assigns(:user).should be_a_new(User)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(save: false, errors: ['Error'])
        post :create, {:user => {  }}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested user" do
        user = User.create! valid_attributes
        User.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => user.to_param, :user => { "these" => "params" }}
      end

      it "assigns the requested user as @user" do
        user = User.create! valid_attributes
        put :update, {:id => user.to_param, :user => {email: 'foo@bar.com'}}
        assigns(:user).should eq(user)
        assigns(:user).email.should == 'foo@bar.com'
      end

      it "redirects to the user" do
        user = User.create! valid_attributes
        put :update, {:id => user.to_param, :user => {email: 'foo@bar.com'}}
        response.should redirect_to(user)
      end
    end

    describe "with invalid params" do
      it "assigns the user as @user" do
        user = User.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => user.to_param, :user => {  }}
        assigns(:user).should eq(user)
      end

      it "re-renders the 'edit' template" do
        user = User.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(save: false, errors: ['ERROR'])
        put :update, {:id => user.to_param, :user => {  }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete :destroy, {:id => user.to_param}
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = User.create! valid_attributes
      delete :destroy, {:id => user.to_param}
      response.should redirect_to(users_url)
    end

    it "does not destroy the current user" do
      expect {
        delete :destroy, {:id => @current_user.to_param}
      }.not_to change(User, :count).by(-1)
      response.should redirect_to(users_url)
    end
  end

end
