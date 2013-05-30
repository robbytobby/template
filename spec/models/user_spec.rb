require 'spec_helper'

describe User do
  context "validations" do
    context "a new user" do
      subject{ FactoryGirl.build :user }
      it { should be_valid }
      it { should_not accept_values_for(:email, '1', '', nil, 'abc', 'ab@d') }
      it { should_not accept_values_for(:first_name, '', ' ', nil) }
      it { should_not accept_values_for(:last_name, '', ' ', nil) }
      it { should accept_values_for(:password, '', ' ', nil) }
    end

    context "a persisted user" do
      subject{ FactoryGirl.create :user, :with_password }
      it { should be_valid }
      it { should_not accept_values_for(:email, '1', '', nil, 'abc', 'ab@d') }
      it { should_not accept_values_for(:first_name, '', ' ', nil) }
      it { should_not accept_values_for(:last_name, '', ' ', nil) }
      it { should_not accept_values_for(:password, '', ' ', nil) }
    end
  end

  context "public methods" do
    subject{ FactoryGirl.create :user, :with_password }

    it "should have the capitalized full_name" do
      subject.full_name.should == "#{subject.first_name} #{subject.last_name}"
    end
  end

end
