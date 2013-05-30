require 'spec_helper'

describe WelcomeController do
  describe "GET 'index'" do
    context "without user logged in" do
      it "redirects to sign" do
        get 'index'
        response.should redirect_to new_user_session_path
      end
    end

    context "with user logged in" do
      login 
      it "returns http success" do
        get 'index'
        response.should be_success
      end
    end
  end
 
end
