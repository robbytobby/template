require 'spec_helper'
include Warden::Test::Helpers

feature "Users" do
  I18n.available_locales.each do |locale|
    background do
      @user = FactoryGirl.create(:user, :confirmed, :with_password)
      @other_user = FactoryGirl.create(:user, :confirmed, :with_password)
    end

    context "without user logged in" do
      scenario "anonymus visits users#index" do
        visit users_path(locale: locale)
        current_path.should == "/#{locale}/users/sign_in"
      end

      scenario "anonymus visits users#show" do
        visit user_path(@user, locale: locale)
        current_path.should == "/#{locale}/users/sign_in"
      end

      scenario "anonymus visits users#new" do
        visit new_user_path(locale: locale)
        current_path.should == "/#{locale}/users/sign_in"
      end

      scenario "anonymus visits users#create" do
        visit users_path(locale: locale, method: :post)
        current_path.should == "/#{locale}/users/sign_in"
      end

      scenario "anonymus visits users#edit" do
        visit edit_user_path(locale: locale, id: @user.to_param)
        current_path.should == "/#{locale}/users/sign_in"
      end
      
      scenario "anonymus visits users#change_password" do
        visit change_password_user_path(locale: locale, id: @user.to_param)
        current_path.should == "/#{locale}/users/sign_in"
      end
    end

    context "with user logged in" do
      background { login_as @user }

      scenario "user visits users#index" do
        visit users_path(locale: locale)
        current_path.should == "/#{locale}/users"
        page.should have_selector 'h1', text: User.model_name.human.pluralize, exact: true
        page.should have_selector 'th', text: User.human_attribute_name(:full_name), exact: true
        page.should have_selector 'th', text: User.human_attribute_name(:email), exact: true
        page.should have_selector 'th', text: I18n.t('helpers.actions'), exact: true
        [@user, @other_user].each do |user|
          within "#user_#{user.id}" do
            page.should have_link user.full_name, href: user_path(user, locale: locale)
            page.should have_selector 'td', text: user.email
            page.should have_link I18n.t('helpers.links.edit'), href: edit_user_path(user, locale: locale)
            page.should have_link I18n.t('helpers.links.destroy'), href: user_path(user, locale: locale)
          end
        end
        page.should have_link I18n.t('helpers.links.new'), href: new_user_path(locale: locale)
      end

      context "add a user" do
        scenario "user adds a new user" do
          old_count = User.count
          visit users_path(locale: locale)
          click_link I18n.t('helpers.links.new')
          current_path.should == new_user_path(locale: locale)
          page.should have_selector 'h1', text: I18n.t('users.new.title')
          fill_in 'user_email', with: 'foo@bar.com'
          fill_in 'user_first_name', with: 'foo'
          fill_in 'user_last_name', with: 'bar'
          click_button I18n.t('helpers.submit.create', model: User.model_name.human)
          User.count.should == old_count + 1
        end

        scenario "user tries to add a new user with an email allready taken" do
          visit users_path(locale: locale)
          click_link I18n.t('helpers.links.new')
          fill_in 'user_email', with: @user.email
          click_button I18n.t('helpers.submit.create', model: User.model_name.human)
          within 'div.control-group.user_email.error' do
            page.should have_selector 'span', text: I18n.t('activerecord.errors.messages.taken')
          end
        end

        scenario "user cancels adding a new user" do
          count = User.count
          visit users_path(locale: locale)
          click_link I18n.t('helpers.links.new')
          click_link I18n.t('helpers.links.cancel')
          current_path.should == users_path(locale: locale)
          User.count.should == count
        end
      end

      context "edit a user" do
        scenario "user edits a user successfully" do
          visit users_path(locale: locale)
          within "#user_#{@other_user.id}" do
            click_link I18n.t('helpers.links.edit')
          end
          current_path.should == edit_user_path(@other_user, locale: locale)
          fill_in 'user_email', with: 'foo@bar.com'
          click_button I18n.t('helpers.submit.update', model: User.model_name.human)
          @other_user.reload.email.should == 'foo@bar.com'
          current_path.should == user_path(@other_user, locale: locale)
        end

        scenario "user edits a user unsuccessfully" do
          visit users_path(locale: locale)
          within "#user_#{@other_user.id}" do
            click_link I18n.t('helpers.links.edit')
          end
          current_path.should == edit_user_path(@other_user, locale: locale)
          fill_in 'user_email', with: @user.email
          click_button I18n.t('helpers.submit.update', model: User.model_name.human)
          @other_user.reload.email.should == @other_user.email
          within 'div.control-group.user_email.error' do
            page.should have_selector 'span', text: I18n.t('activerecord.errors.messages.taken')
          end
        end

        scenario "user cancels editing a user" do
          visit users_path(locale: locale)
          within "#user_#{@other_user.id}" do
            click_link I18n.t('helpers.links.edit')
          end
          click_link I18n.t('helpers.links.cancel')
          current_path.should == users_path(locale: locale)
          @other_user.should == @other_user.reload
        end
      end

      scenario "deleting a user" do
        pending
      end
    end
  end
end
