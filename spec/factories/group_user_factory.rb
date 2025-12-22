FactoryBot.define do
  factory :group_user do
    association :group
    association :user
    relation { "student" }

    trait :teacher do
      relation { "teacher" }
      association :user, factory: [ :user, :teacher ]
    end

    trait :student do
      relation { "student" }
      association :user, factory: [ :user, :student ]
    end
  end
end
