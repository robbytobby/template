module ControllerMacros
  #def login_with_type(type)
  #  before(:each) do
  #    @request.env["devise.mapping"] = Devise.mappings[:user]
  #    FactoryGirl.create(:role, name: type) unless Role.find_by_name(type.to_s)
  #    user = FactoryGirl.create(type)
  #    user.address = FactoryGirl.create(:staff)
  #    user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the confirmable module
  #    @current_user = user
  #    sign_in user
  #  end
  #end

  def login
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user, :with_password, :confirmed)
      @current_user = user
      sign_in user
    end
  end
end
