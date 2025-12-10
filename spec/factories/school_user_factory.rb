FactoryBot.define do
  factory :school_user do
    association :school
    association :user, factory: :user, roles: [ :student ]
    relation { "student" }

    trait :instructor do
      association :user, factory: :user, roles: [ :instructor ]
      relation { "instructor" }
    end

    trait :facilitator do
      association :user, factory: :user, roles: [ :facilitator ]
      relation { "facilitator" }
    end

    trait :principal do
      association :user, factory: :user, roles: [ :admin ]
      relation { "principal" }
    end
  end
end
