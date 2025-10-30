FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "Password123" }
    username { Faker::Internet.unique.username(specifier: 5..8) }
  end
end
