FactoryBot.define do
  factory :profile do
    association :user

    after(:build) do |profile|
      profile.id = profile.user.id if profile.user.present?
    end

    name { Faker::Name.name }
    bio { Faker::Lorem.paragraph }
    avatar_url { Faker::Avatar.image }
    alternate_mobile_number { "+#{Faker::Number.number(digits: 12)}" }
    address { Faker::Address.full_address }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    father_name { Faker::Name.male_first_name }
    mother_name { Faker::Name.female_first_name }
    gender { %w[male female other].sample }

    trait :teacher do
      teacher_detail do
        {
          subjects_taught: "Mathematics, Physics, Chemistry",
          years_experience: Faker::Number.between(from: 1, to: 30),
          qualification: "Master's in Education"
        }
      end
    end

    trait :student do
      student_details do
        {
          grade_level: "Grade #{Faker::Number.between(from: 1, to: 12)}",
          enrollment_date: Faker::Date.between(from: 2.years.ago, to: Date.today).to_s,
          parent_contact: "+#{Faker::Number.number(digits: 12)}"
        }
      end
    end
  end
end
