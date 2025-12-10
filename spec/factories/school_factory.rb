FactoryBot.define do
  factory :school do
    sequence(:steamer_id) { |n| n }
    school_name { Faker::University.name }
    district { Faker::Address.city }
    city_village { Faker::Address.community }
    pincode { Faker::Number.number(digits: 6) }
    landmark { Faker::Address.street_name }
    address { Faker::Address.full_address }
  end
end
