FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "Password123" }
    username { Faker::Internet.unique.username(specifier: 5..8) }
    roles { [] }

    trait :admin do
      roles { [:admin] }
    end

    trait :system_user do
      roles { [:system_user] }
    end

    trait :instructor do
      roles { [:instructor] }
    end

    trait :facilitator do
      roles { [:facilitator] }
    end

    trait :student do
      roles { [:student] }
    end
  end
end
