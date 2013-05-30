# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email){|n| "test_#{n}@example.com"}
    sequence(:first_name) { |n| "foo_#{n}" }
    sequence(:last_name) { |n| "foo_#{n}" }

    trait :with_password do
      password '12345678'
      password_confirmation '12345678'
    end

    trait :confirmed do
      confirmed_at Time.now
    end
  end
end
