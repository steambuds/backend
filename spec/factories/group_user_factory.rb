FactoryBot.define do
  factory :group_user do
    association :group
    association :user
    relation { "student" }

    trait :instructor do
      relation { "instructor" }
    end

    trait :facilitator do
      relation { "facilitator" }
    end

    trait :student do
      relation { "student" }
    end
  end
end
