FactoryBot.define do
  factory :hello do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    description { Faker::Lorem.paragraph }
    mobile_number { Faker::PhoneNumber.cell_phone_in_e164 }
    category { Faker::Commerce.department }
  end
end