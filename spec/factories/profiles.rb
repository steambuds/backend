FactoryBot.define do
  factory :profile do
    association :user
    bio { Faker::Lorem.paragraph }
    avatar_url { Faker::Avatar.image }
    phone { "+#{Faker::Number.number(digits: 12)}" }
    address { Faker::Address.full_address }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }

    trait :teacher do
      user_type { "teacher" }
      subjects_taught { "Mathematics, Physics, Chemistry" }
      years_experience { Faker::Number.between(from: 1, to: 30) }
      qualification { "Master's in Education" }
    end

    trait :student do
      user_type { "student" }
      grade_level { "Grade #{Faker::Number.between(from: 1, to: 12)}" }
      enrollment_date { Faker::Date.between(from: 2.years.ago, to: Date.today) }
      parent_contact { "+#{Faker::Number.number(digits: 12)}" }
    end
  end
end
