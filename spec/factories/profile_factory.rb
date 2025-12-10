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
      roll_specific_detail do
        {
          teacher: {
            subjects: [ "Mathematics", "Physics", "Chemistry" ],
            years_of_experience: Faker::Number.between(from: 1, to: 30),
            qualification: "Master's in Education"
          }
        }
      end
    end

    trait :student do
      roll_specific_detail do
        {
          student: {
            grade: "#{Faker::Number.between(from: 1, to: 12)}",
            section: "A",
            roll_number: "#{Faker::Number.between(from: 1, to: 50)}",
            enrollment_date: Faker::Date.between(from: 2.years.ago, to: Date.today).to_s
          }
        }
      end
    end
  end
end
