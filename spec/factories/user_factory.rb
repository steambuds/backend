FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "Password123" }
    username { Faker::Internet.unique.username(specifier: 5..8) }
    roles { [] }

    trait :admin do
      roles { [ :admin ] }
    end

    trait :system do
      roles { [ :system ] }
    end

    trait :school_admin do
      roles { [ :school_admin ] }
    end

    trait :teacher do
      roles { [ :teacher ] }
    end

    trait :guardian do
      roles { [ :guardian ] }
    end

    trait :student do
      roles { [ :student ] }
    end
  end
end
