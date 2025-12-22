FactoryBot.define do
  factory :school_user do
    association :school
    association :user
    relation { "student" }

    trait :teacher do
      association :user, factory: :user, roles: [ :teacher ]
      relation { "teacher" }
    end
  end
end
