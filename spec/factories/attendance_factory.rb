FactoryBot.define do
  factory :attendance do
    association :group
    association :user
    attendance_at { Time.current }
    status { "present" }

    trait :present do
      status { "present" }
    end

    trait :absent do
      status { "absent" }
    end

    trait :late do
      status { "late" }
    end

    trait :excused do
      status { "excused" }
    end
  end
end
