FactoryBot.define do
  factory :user_role do
    user
    role { :admin }

    trait :admin do
      role { :admin }
    end

    trait :server_machine do
      role { :server_machine }
    end

    trait :manager do
      role { :manager }
    end
  end
end
