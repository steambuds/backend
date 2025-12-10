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

      it "is valid with minimal attributes" do
        profile = build(:profile, user: user)
        expect(profile).to be_valid
      end
    end

    context "gender validation" do
      it "allows valid gender values" do
        %w[male female other].each do |gender|
          profile = build(:profile, user: user, gender: gender)
          expect(profile).to be_valid
        end
      end

      it "rejects invalid gender values" do
        profile = build(:profile, user: user, gender: "invalid")
        expect(profile).not_to be_valid
        expect(profile.errors[:gender]).to include("invalid is not a valid gender")
      end

      it "allows blank gender" do
        profile = build(:profile, user: user, gender: nil)
        expect(profile).to be_valid
      end
    end

    context "steamer_id validation" do
      it "enforces unique steamer_id" do
        create(:profile, user: user, steamer_id: 12345)
        user2 = create(:user, username: "user2", email: "user2@example.com")
        duplicate_profile = build(:profile, user: user2, steamer_id: 12345)
        expect(duplicate_profile).not_to be_valid
        expect(duplicate_profile.errors[:steamer_id]).to include("has already been taken")
      end

      it "allows nil steamer_id" do
        profile = build(:profile, user: user, steamer_id: nil)
        expect(profile).to be_valid
      end
    end

    context "common field validations" do
      it "validates alternate_mobile_number format when present" do
        profile = build(:profile, user: user, alternate_mobile_number: "invalid")
        expect(profile).not_to be_valid
        expect(profile.errors[:alternate_mobile_number]).to include("must be a valid phone number (10-15 digits, optional +)")
      end

      it "allows valid alternate_mobile_number formats" do
        profile = build(:profile, user: user, alternate_mobile_number: "+1234567890")
        expect(profile).to be_valid
      end

      it "allows blank alternate_mobile_number" do
        profile = build(:profile, user: user, alternate_mobile_number: nil)
        expect(profile).to be_valid
      end

      it "validates date_of_birth is in the past" do
        profile = build(:profile, user: user, date_of_birth: Date.tomorrow)
        expect(profile).not_to be_valid
        expect(profile.errors[:date_of_birth]).to include("must be less than #{Date.current}")
      end

      it "allows valid date_of_birth" do
        profile = build(:profile, user: user, date_of_birth: 30.years.ago)
        expect(profile).to be_valid
      end

      it "allows blank date_of_birth" do
        profile = build(:profile, user: user, date_of_birth: nil)
        expect(profile).to be_valid
      end
    end
  end

  describe "JSONB fields" do
    let(:user) { create(:user) }

    it "initializes roll_specific_detail as empty hash by default" do
      profile = Profile.new(id: user.id)
      expect(profile.roll_specific_detail).to eq({})
    end

    it "initializes experience as empty hash by default" do
      profile = Profile.new(id: user.id)
      expect(profile.experience).to eq({})
    end

    it "stores and retrieves teacher data in roll_specific_detail" do
      profile = create(:profile, :teacher, user: user)
      expect(profile.roll_specific_detail).to be_a(Hash)
      expect(profile.roll_specific_detail["teacher"]).to be_present
      expect(profile.roll_specific_detail["teacher"]["subjects"]).to be_present
    end

    it "stores and retrieves student data in roll_specific_detail" do
      profile = create(:profile, :student, user: user)
      expect(profile.roll_specific_detail).to be_a(Hash)
      expect(profile.roll_specific_detail["student"]).to be_present
      expect(profile.roll_specific_detail["student"]["grade"]).to be_present
    end
  end

  describe "composite primary key" do
    let(:user) { create(:user) }

    it "uses user.id as profile.id" do
      profile = create(:profile, user: user)
      expect(profile.id).to eq(user.id)
    end

    it "enforces one profile per user via id constraint" do
      create(:profile, user: user)
      duplicate_profile = Profile.new(id: user.id, name: "Duplicate")
      expect { duplicate_profile.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
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
