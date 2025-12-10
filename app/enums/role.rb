# frozen_string_literal: true

# Role enum defining all available roles in the system
# These roles are used in:
# - users.roles (array of roles a user has)
# - group_users.relation (user's role within a group)
# - school_users.relation (user's role within a school)
module Role
  ADMIN = :admin
  SYSTEM_USER = :system_user
  INSTRUCTOR = :instructor
  FACILITATOR = :facilitator
  STUDENT = :student

  ALL = [ ADMIN, SYSTEM_USER, INSTRUCTOR, FACILITATOR, STUDENT ].freeze

  def self.valid?(role)
    ALL.include?(role.to_sym)
  end

  def self.values
    ALL
  end
end
