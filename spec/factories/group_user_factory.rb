FactoryBot.define do
  factory :group_user do
    association :group
    association :user
    relation { "student" }

    trait :instructor do
      relation { "instructor" }
      association :user, factory: [:user, :instructor]
    end

    trait :facilitator do
      relation { "facilitator" }
      association :user, factory: [:user, :facilitator]
    end

    trait :student do
      relation { "student" }
      association :user, factory: [:user, :student]
    end
  end
end
