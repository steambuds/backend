FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { "Password123" }
    username { Faker::Internet.unique.username(specifier: 5..8) }

    trait :with_admin_role do
      after(:create) do |user|
        create(:user_role, user: user, role: :admin)
      end
    end

    trait :with_server_machine_role do
      after(:create) do |user|
        create(:user_role, user: user, role: :server_machine)
      end
    end

    trait :with_manager_role do
      after(:create) do |user|
        create(:user_role, user: user, role: :manager)
      end
    end
  end
end
