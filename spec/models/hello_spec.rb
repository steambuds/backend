require 'rails_helper'

RSpec.describe Hello, type: :model do
  subject { build(:hello) }

  it "is valid with all required attributes and valid email/mobile" do
    expect(subject).to be_valid
  end

  it "is invalid without a name" do
    subject.name = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:name]).to include("can't be blank")
  end

  it "is invalid without a description" do
    subject.description = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:description]).to include("can't be blank")
  end

  it "is invalid without a category" do
    subject.category = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:category]).to include("can't be blank")
  end

  it "is invalid with an incorrect email format" do
    subject.email = "invalid_email"
    expect(subject).not_to be_valid
    expect(subject.errors[:email]).to include("is invalid")
  end

  it "is invalid with an incorrect mobile number format" do
    subject.mobile_number = "12345"
    expect(subject).not_to be_valid
    expect(subject.errors[:mobile_number]).to include("must be a valid mobile number (10-15 digits, optional +)")
  end

  it "is valid with only email present" do
    subject.mobile_number = nil
    expect(subject).to be_valid
  end

  it "is valid with only mobile number present" do
    subject.email = nil
    expect(subject).to be_valid
  end

  it "is invalid if both email and mobile number are blank" do
    subject.email = nil
    subject.mobile_number = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:base]).to include("Either email or mobile number must be present")
  end
end