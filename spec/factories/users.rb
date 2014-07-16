# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
  	sequence(:email) { |n| "est#{n}@example.com" }
    mobile_number '123456789123'
    first_name 'test'
  end
end
