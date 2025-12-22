FactoryBot.define do
  factory :school_user do
    association :school
    association :user
    relation { "student" }

    trait :teacher do
      association :user, factory: :user, roles: [ :teacher ]
      relation { "teacher" }
    end

    trait :guardian do
      association :user, factory: :user, roles: [ :guardian ]
      relation { "guardian" }
    end

    trait :school_admin do
      association :user, factory: :user, roles: [ :school_admin ]
      relation { "school_admin" }
    end
  end
end
