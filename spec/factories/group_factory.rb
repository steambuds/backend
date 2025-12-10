FactoryBot.define do
  factory :group do
    name { "Group #{SecureRandom.hex(4)}" }
    about { "About this group" }
    grades { "Grade 1-5" }
    same_school { false }
  end
end
