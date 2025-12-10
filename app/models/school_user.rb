class SchoolUser < ApplicationRecord
  has_paper_trail

  self.primary_key = [:school_id, :user_id]
  belongs_to :school
  belongs_to :user

  validates :relation, presence: true
  validate :relation_is_valid_role
  validate :user_has_required_role

  # Convert relation to symbol for consistent usage
  def relation
    read_attribute(:relation)&.to_sym
  end

  # Override relation= to store as string in database
  def relation=(value)
    write_attribute(:relation, value.to_s)
  end

  private

  def relation_is_valid_role
    return if relation.nil?

    unless Role.valid?(relation)
      errors.add(:relation, "must be a valid role. Valid roles are: #{Role.values.join(', ')}")
    end
  end

  def user_has_required_role
    return if relation.nil? || user.nil?

    unless user.has_role?(relation)
      errors.add(:base, "User must have the '#{relation}' role to be assigned as #{relation} in a school")
    end
  end
end
