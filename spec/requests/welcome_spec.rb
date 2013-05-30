require 'spec_helper'
include Warden::Test::Helpers

feature "Welcome" do

  I18n.available_locales.each do |locale|
    context "with unconfirmed user" do
      background { @user = FactoryGirl.create(:user) }

      scenario "user tries to log in" do
        visit root_url(locale: locale)
        fill_in 'user_email', with: @user.email 
        click_button I18n.t('devise.sessions.new.sign_in')
        current_path.should == "/#{locale}/users/sign_in"
        page.should have_selector 'div.alert.alert-error', text: I18n.t('devise.failure.invalid')
      end

      context "user visits confirmation link" do
        scenario "gets logged in and confirmed afterwards" do
          visit user_confirmation_path(confirmation_token: @user.confirmation_token, locale: locale)
          @user.reload.should be_confirmed
          current_path.should_not == "/#{locale}/users/sign_in"
        end

        scenario "is forced to change its password before anythin else" do
          visit user_confirmation_path(confirmation_token: @user.confirmation_token, locale: locale)
          current_path.should == "/#{locale}/users/#{@user.id}/change_password"
          click_link I18n.t('layouts.navbar.users')
          current_path.should == "/#{locale}/users/#{@user.id}/change_password"
          click_link I18n.t('layouts.navbar.users')
        end

        scenario "after changing its password, user can move freely" do
          visit user_confirmation_path(confirmation_token: @user.confirmation_token, locale: locale)
          current_path.should == "/#{locale}/users/#{@user.id}/change_password"
          fill_in 'user_password', with: '12345678'
          fill_in 'user_password_confirmation', with: '12345678'
          click_button I18n.t('helpers.submit.update', model: User.human_attribute_name(:password))
          current_path.should == welcome_index_path(locale: locale)
        end
      end

    end
    
    context "with confirmed user" do
      background { @user = FactoryGirl.create(:user, :confirmed, password: '12345678', password_confirmation: '12345678') }

      context "No user is logged in (locale: #{locale})" do
        background { visit root_url(locale: locale) }

        scenario "anonymus visits index" do
          current_path.should == "/#{locale}/users/sign_in"
          page.should have_selector 'h2', text: I18n.t('devise.sessions.new.sign_in')
          page.should_not have_selector 'ul.nav'
          page.should_not have_selector 'div.sidebar-nav'
          page.should have_link I18n.t('devise.shared.links.forgot_your_password?'), href: "/#{locale}/users/password/new"
          page.should have_link I18n.t('devise.shared.links.did_not_receive_unlock_instructions?'), href: "/#{locale}/users/unlock/new"
          page.should have_link I18n.t('devise.shared.links.did_not_receive_confirmation_instructions?'), href: "/#{locale}/users/confirmation/new"
        end

        scenario "anonymus changes locale (locale: #{locale})" do
          current_path.should == "/#{locale}/users/sign_in"
          (I18n.available_locales - [locale]).each do |new_locale|
            click_link new_locale
            current_path.should == "/#{new_locale}/users/sign_in"
          end

        end

        context "User tries to log in" do
          background { fill_in 'user_email', with: @user.email }

          scenario "User logges in with correct credentials (locale: #{locale})" do
            fill_in 'user_password', with: @user.password
            click_button I18n.t('devise.sessions.new.sign_in')
            page.should_not have_content I18n.t('devise.sessions.new.sign_in')
            page.should have_selector 'div.alert.alert-success', text: I18n.t('devise.sessions.signed_in')
            current_path.should == "/#{locale}"
          end

          scenario "User logges in with incorrect credentials (locale: #{locale})" do
            fill_in 'user_password', with: '87654321'
            click_button I18n.t('devise.sessions.new.sign_in')
            page.should have_selector 'div.alert.alert-error', text: I18n.t('devise.failure.invalid')
            current_path.should == "/#{locale}/users/sign_in"
          end
        end

        scenario "User has forgotten his password (locale: #{locale})" do
          click_link I18n.t('devise.shared.links.forgot_your_password?')
          current_path.should == "/#{locale}/users/password/new"
        end

        scenario "User did not get unlock instructions  (locale: #{locale})" do
          click_link I18n.t('devise.shared.links.did_not_receive_unlock_instructions?')
          current_path.should == "/#{locale}/users/unlock/new"
        end

        scenario "User did not get actitvation instructions  (locale: #{locale})" do
          click_link I18n.t('devise.shared.links.did_not_receive_confirmation_instructions?')
          current_path.should == "/#{locale}/users/confirmation/new"
        end
      end

      context "a user is logged in (locale: #{locale})" do
        background { login_as @user; visit root_url(locale: locale) }

        scenario "User is logged in (locale: #{locale})" do
          current_path.should == "/"
          page.should_not have_content I18n.t('devise.sessions.new.sign_in')
          page.should have_selector 'ul.nav'
          page.should have_selector 'div.sidebar-nav'
        end
      end
    end
  end
end
