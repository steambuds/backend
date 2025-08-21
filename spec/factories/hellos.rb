FactoryBot.define do
  factory :hello do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    description { Faker::Lorem.paragraph }
    subject { Faker::Lorem.sentence }
    category { Faker::Commerce.department }
  end
end