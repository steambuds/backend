require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  let(:user) { User.create!(username: 'test', email: 'test@example.com', password: 'Password123') }

  it 'is valid with valid attributes' do
    subject = described_class.new(user: user)
    expect(subject).to be_valid
  end

  it 'is not valid without a user' do
    subject = described_class.new(user: nil)
    expect(subject).not_to be_valid
  end

  it 'generates a token before validation on create' do
    subject = described_class.new(user: user)
    subject.valid? # trigger validations
    expect(subject.token).not_to be_nil
  end

  it 'requires a unique token' do
    first_token = described_class.create!(user: user)
    second_token = described_class.new(user: user, token: first_token.token)
    expect(second_token).not_to be_valid
    expect(second_token.errors[:token]).to include('has already been taken')
  end
end