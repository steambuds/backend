require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe "associations" do
    it "belongs to user" do
      profile = build(:profile, :teacher)
      expect(profile.user).to be_present
    end
  end

  describe "validations" do
    let(:user) { create(:user) }

    context "basic validations" do
      it "is valid with valid teacher attributes" do
        profile = build(:profile, :teacher, user: user)
        expect(profile).to be_valid
      end

      it "is valid with valid student attributes" do
        profile = build(:profile, :student, user: user)
        expect(profile).to be_valid
      end

      it "requires user_type to be present" do
        profile = build(:profile, user: user, user_type: nil)
        expect(profile).not_to be_valid
        expect(profile.errors[:user_type]).to include("can't be blank")
      end

      it "enforces unique user_id" do
        create(:profile, :teacher, user: user)
        duplicate_profile = build(:profile, :student, user: user)
        expect(duplicate_profile).not_to be_valid
        expect(duplicate_profile.errors[:user_id]).to include("has already been taken")
      end
    end

    context "teacher-specific validations" do
      it "requires subjects_taught for teachers" do
        profile = build(:profile, user: user, user_type: "teacher", subjects_taught: nil)
        expect(profile).not_to be_valid
        expect(profile.errors[:subjects_taught]).to include("can't be blank")
      end

      it "validates years_experience is a positive integer" do
        profile = build(:profile, :teacher, user: user, years_experience: -5)
        expect(profile).not_to be_valid
        expect(profile.errors[:years_experience]).to include("must be greater than or equal to 0")
      end

      it "allows nil years_experience for teachers" do
        profile = build(:profile, :teacher, user: user, years_experience: nil)
        expect(profile).to be_valid
      end
    end

    context "student-specific validations" do
      it "requires grade_level for students" do
        profile = build(:profile, user: user, user_type: "student", grade_level: nil)
        expect(profile).not_to be_valid
        expect(profile.errors[:grade_level]).to include("can't be blank")
      end

      it "requires enrollment_date for students" do
        profile = build(:profile, user: user, user_type: "student", enrollment_date: nil)
        expect(profile).not_to be_valid
        expect(profile.errors[:enrollment_date]).to include("can't be blank")
      end
    end

    context "common field validations" do
      it "validates phone format when present" do
        profile = build(:profile, :teacher, user: user, phone: "invalid")
        expect(profile).not_to be_valid
        expect(profile.errors[:phone]).to include("must be a valid phone number (10-15 digits, optional +)")
      end

      it "allows valid phone formats" do
        profile = build(:profile, :teacher, user: user, phone: "+1234567890")
        expect(profile).to be_valid
      end

      it "allows blank phone" do
        profile = build(:profile, :teacher, user: user, phone: nil)
        expect(profile).to be_valid
      end

      it "validates date_of_birth is in the past" do
        profile = build(:profile, :teacher, user: user, date_of_birth: Date.tomorrow)
        expect(profile).not_to be_valid
        expect(profile.errors[:date_of_birth]).to include("must be less than #{Date.current}")
      end

      it "allows valid date_of_birth" do
        profile = build(:profile, :teacher, user: user, date_of_birth: 30.years.ago)
        expect(profile).to be_valid
      end

      it "allows blank date_of_birth" do
        profile = build(:profile, :teacher, user: user, date_of_birth: nil)
        expect(profile).to be_valid
      end
    end
  end

  describe "enum user_type" do
    it "allows 'teacher' as user_type" do
      profile = build(:profile, :teacher)
      expect(profile.user_type).to eq("teacher")
    end

    it "allows 'student' as user_type" do
      profile = build(:profile, :student)
      expect(profile.user_type).to eq("student")
    end

    it "is invalid with an invalid user_type" do
      profile = build(:profile, :teacher)
      profile.user_type = "invalid"
      expect(profile).not_to be_valid
      expect(profile.errors[:user_type]).to include("is not included in the list")
    end
  end

  describe "#teacher? and #student?" do
    it "returns true for teacher? when user_type is teacher" do
      profile = build(:profile, :teacher)
      expect(profile.teacher?).to be true
      expect(profile.student?).to be false
    end

    it "returns true for student? when user_type is student" do
      profile = build(:profile, :student)
      expect(profile.student?).to be true
      expect(profile.teacher?).to be false
    end
  end

  describe "dependent destroy" do
    it "is destroyed when associated user is destroyed" do
      user = create(:user)
      profile = create(:profile, :teacher, user: user)
      expect { user.destroy }.to change { Profile.count }.by(-1)
    end
  end
end
