# Clear existing data
puts "Cleaning database..."
Attendance.destroy_all
GroupUser.destroy_all
Group.destroy_all
SchoolUser.destroy_all
School.destroy_all
RefreshToken.destroy_all
Profile.destroy_all
User.destroy_all

puts "Database cleaned."

# Helper to create user with roles
def create_user(username, roles = [], profile_data = {})
  email = "#{username.downcase.gsub(' ', '.')}@steambuds.com"
  user = User.create!(
    username: username,
    email: email,
    password: "Password123",
    mobile_number: "+91#{rand(6000000000..9999999999)}",
    roles: roles  # Set roles directly as array
  )

  Profile.create!(
    id: user.id,
    name: username,
    steamer_id: 9000000 + User.count,
    bio: "Bio for #{username}",
    **profile_data
  )

  puts "Created user: #{username} (roles: #{roles.join(', ')})"
  user
end

puts "\n=== Creating Users ==="

# 1. Create Admin
admin = create_user("Ghanshyam", [:admin], {
  bio: "System Administrator",
  gender: "male"
})

# 2. Create Teachers/Instructors (2)
teacher1 = create_user("Priya Sharma", [:instructor], {
  roll_specific_detail: {
    qualification: "B.Ed in Mathematics",
    years_of_experience: 5,
    subjects: ["Mathematics", "Physics"]
  },
  gender: "female"
})

teacher2 = create_user("Rajesh Kumar", [:instructor], {
  roll_specific_detail: {
    qualification: "M.Sc in Biology",
    years_of_experience: 8,
    subjects: ["Biology", "Chemistry", "Science"]
  },
  gender: "male"
})

# 3. Create Facilitators (2)
facilitator1 = create_user("Anjali Verma", [:facilitator], {
  bio: "Community Facilitator - STEAM Program Coordinator",
  gender: "female"
})

facilitator2 = create_user("Vikram Singh", [:facilitator], {
  bio: "Field Facilitator - Student Support Specialist",
  gender: "male"
})

# 4. Create Guardians (2 - no special roles, just regular users)
guardian1 = create_user("Ramesh Patel", [], {
  bio: "Parent of Aarav Patel",
  gender: "male"
})

guardian2 = create_user("Sunita Reddy", [], {
  bio: "Parent of Diya Reddy",
  gender: "female"
})

# 5. Create Students (14)
student_names = [
  { name: "Aarav Patel", gender: "male", grade: "9", section: "A" },
  { name: "Diya Reddy", gender: "female", grade: "9", section: "A" },
  { name: "Arjun Mehta", gender: "male", grade: "9", section: "B" },
  { name: "Ishita Gupta", gender: "female", grade: "9", section: "B" },
  { name: "Rohan Das", gender: "male", grade: "10", section: "A" },
  { name: "Sneha Iyer", gender: "female", grade: "10", section: "A" },
  { name: "Kabir Joshi", gender: "male", grade: "10", section: "B" },
  { name: "Ananya Nair", gender: "female", grade: "10", section: "B" },
  { name: "Aditya Singh", gender: "male", grade: "9", section: "C" },
  { name: "Meera Desai", gender: "female", grade: "9", section: "C" },
  { name: "Karan Malhotra", gender: "male", grade: "10", section: "C" },
  { name: "Pooja Sharma", gender: "female", grade: "10", section: "C" },
  { name: "Vihan Kapoor", gender: "male", grade: "9", section: "A" },
  { name: "Riya Bansal", gender: "female", grade: "10", section: "A" }
]

students = student_names.map do |s|
  create_user(s[:name], [:student], {
    roll_specific_detail: {
      grade: s[:grade],
      section: s[:section],
      roll_number: rand(1..50),
      enrollment_date: Date.today - rand(365..730).days
    },
    gender: s[:gender],
    date_of_birth: Date.today - rand(14..16).years
  })
end

puts "\n=== Creating Schools ==="

# Create 3 Schools
school1 = School.create!(
  steamer_id: 1001,
  school_name: "Greenwood Public School",
  district: "North District",
  city_village: "Mumbai",
  pincode: 400001,
  address: "123 MG Road, Andheri",
  created_by: admin.id,
  updated_by: admin.id
)
puts "Created school: #{school1.school_name}"

school2 = School.create!(
  steamer_id: 1002,
  school_name: "Sunnydale High School",
  district: "South District",
  city_village: "Mumbai",
  pincode: 400002,
  address: "456 Link Road, Bandra",
  created_by: admin.id,
  updated_by: admin.id
)
puts "Created school: #{school2.school_name}"

school3 = School.create!(
  steamer_id: 1003,
  school_name: "Riverside Academy",
  district: "Central District",
  city_village: "Mumbai",
  pincode: 400003,
  address: "789 SV Road, Goregaon",
  created_by: admin.id,
  updated_by: admin.id
)
puts "Created school: #{school3.school_name}"

puts "\n=== Assigning Users to Schools ==="

# Assign teachers to schools (users must have :instructor role)
SchoolUser.create!(
  school: school1,
  user: teacher1,
  relation: :instructor,
  created_by: admin.id,
  updated_by: admin.id
)
puts "  #{teacher1.profile.name} → #{school1.school_name} (instructor)"

SchoolUser.create!(
  school: school2,
  user: teacher2,
  relation: :instructor,
  created_by: admin.id,
  updated_by: admin.id
)
puts "  #{teacher2.profile.name} → #{school2.school_name} (instructor)"

# Assign facilitators to schools
SchoolUser.create!(
  school: school1,
  user: facilitator1,
  relation: :facilitator,
  created_by: admin.id,
  updated_by: admin.id
)
SchoolUser.create!(
  school: school3,
  user: facilitator2,
  relation: :facilitator,
  created_by: admin.id,
  updated_by: admin.id
)

# Assign students to schools (users must have :student role)
# School 1: 6 students
school1_students = students[0..5]
school1_students.each do |student|
  SchoolUser.create!(
    school: school1,
    user: student,
    relation: :student,
    created_by: admin.id,
    updated_by: admin.id
  )
  puts "  #{student.profile.name} → #{school1.school_name} (student)"
end

# School 2: 5 students
school2_students = students[6..10]
school2_students.each do |student|
  SchoolUser.create!(
    school: school2,
    user: student,
    relation: :student,
    created_by: admin.id,
    updated_by: admin.id
  )
  puts "  #{student.profile.name} → #{school2.school_name} (student)"
end

# School 3: 3 students
school3_students = students[11..13]
school3_students.each do |student|
  SchoolUser.create!(
    school: school3,
    user: student,
    relation: :student,
    created_by: admin.id,
    updated_by: admin.id
  )
  puts "  #{student.profile.name} → #{school3.school_name} (student)"
end

puts "\n=== Creating Groups ==="

# Group 1: All students from SAME school (School 1 - Greenwood)
group1 = Group.create!(
  name: "Greenwood Math Champions",
  about: "Advanced Mathematics study group for Grade 9 & 10 students",
  grades: "9,10",
  same_school: true,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(
  group: group1,
  user: teacher1,
  relation: :instructor,
  created_by: admin.id,
  updated_by: admin.id
)
school1_students.each do |student|
  GroupUser.create!(
    group: group1,
    user: student,
    relation: :student,
    created_by: admin.id,
    updated_by: admin.id
  )
end
puts "✓ Group 1: #{group1.name}"
puts "  - Same school: YES (#{school1.school_name})"
puts "  - Instructor: #{teacher1.profile.name}"
puts "  - Students: #{school1_students.count}"

# Group 2: Students from DIFFERENT schools (mixed)
group2 = Group.create!(
  name: "Inter-School Science Explorers",
  about: "Multi-school collaborative science project",
  grades: "9,10",
  same_school: false,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(
  group: group2,
  user: teacher2,
  relation: :instructor,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(
  group: group2,
  user: facilitator1,
  relation: :facilitator,
  created_by: admin.id,
  updated_by: admin.id
)
# Mix: 3 from School 1, 3 from School 2, 2 from School 3
mixed_students = [
  students[0], students[2], students[4],  # School 1
  students[6], students[7], students[9],  # School 2
  students[11], students[12]              # School 3
]
mixed_students.each do |student|
  GroupUser.create!(
    group: group2,
    user: student,
    relation: :student,
    created_by: admin.id,
    updated_by: admin.id
  )
end
puts "✓ Group 2: #{group2.name}"
puts "  - Same school: NO (Mixed schools)"
puts "  - Instructor: #{teacher2.profile.name}"
puts "  - Facilitator: #{facilitator1.profile.name}"
puts "  - Students: #{mixed_students.count} (from 3 schools)"

# Group 3: Facilitator-led community group (any type)
group3 = Group.create!(
  name: "Weekend STEAM Club",
  about: "Weekend enrichment program - Art, Robotics, and Creative Thinking",
  grades: "9,10,All",
  same_school: false,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(
  group: group3,
  user: facilitator2,
  relation: :facilitator,
  created_by: admin.id,
  updated_by: admin.id
)
# Random selection: 6 students
group3_students = [students[1], students[3], students[5], students[8], students[10], students[13]]
group3_students.each do |student|
  GroupUser.create!(
    group: group3,
    user: student,
    relation: :student,
    created_by: admin.id,
    updated_by: admin.id
  )
end
puts "✓ Group 3: #{group3.name}"
puts "  - Same school: NO (Community-based)"
puts "  - Facilitator: #{facilitator2.profile.name}"
puts "  - Students: #{group3_students.count}"

puts "\n=== Creating Attendance Records ==="

# Generate attendance for the past 30 days (weekends excluded)
groups = [group1, group2, group3]
dates = (0..29).map { |i| Date.today - i.days }

attendance_summary = {}

groups.each_with_index do |group, idx|
  group_students = group.users.joins(:group_users).where(group_users: { relation: 'student', group_id: group.id }).distinct
  attendance_count = 0

  # Get the instructor/facilitator for this group to use as created_by
  instructor = group.users.joins(:group_users).where(group_users: { relation: ['instructor', 'facilitator'], group_id: group.id }).first

  dates.each_with_index do |date, day_idx|
    # Skip weekends
    next if date.saturday? || date.sunday?

    group_students.each do |student|
      # Realistic attendance patterns
      rand_val = rand(100)
      status = if date.monday? && [students[2], students[7]].include?(student)
        :late  # Some students consistently late on Mondays
      elsif day_idx >= 20 && [students[5], students[10]].include?(student)
        :excused  # Some students excused for last 10 days
      elsif rand_val < 85
        :present
      elsif rand_val < 90
        :late
      elsif rand_val < 95
        :excused
      else
        :absent
      end

      Attendance.create!(
        group: group,
        user: student,
        attendance_at: date.to_time.change(hour: 9, min: 0),
        status: status,
        created_by: instructor&.id || admin.id,
        updated_by: instructor&.id || admin.id
      )
      attendance_count += 1
    end
  end

  attendance_summary["Group #{idx + 1}"] = {
    name: group.name,
    students: group_students.count,
    attendance_records: attendance_count
  }
end

puts "\nAttendance Summary:"
attendance_summary.each do |key, data|
  puts "  #{key} (#{data[:name]}): #{data[:attendance_records]} records for #{data[:students]} students"
end

puts "\n" + "="*60
puts "SEEDING COMPLETED SUCCESSFULLY!"
puts "="*60
puts "\nLogin Credentials (all passwords: Password123):"
puts "  Admin:       #{admin.email}"
puts "  Teacher 1:   #{teacher1.email}"
puts "  Teacher 2:   #{teacher2.email}"
puts "  Facilitator: #{facilitator1.email}"
puts "\nDatabase Summary:"
puts "  Users:      #{User.count} (1 admin, 2 instructors, 2 facilitators, 2 guardians, 14 students)"
puts "  Schools:    #{School.count}"
puts "  Groups:     #{Group.count}"
puts "  Attendance: #{Attendance.count} records"
puts "\nRole Assignments:"
puts "  Admin:         #{User.where("'admin' = ANY(roles)").count}"
puts "  Instructors:   #{User.where("'instructor' = ANY(roles)").count}"
puts "  Facilitators:  #{User.where("'facilitator' = ANY(roles)").count}"
puts "  Students:      #{User.where("'student' = ANY(roles)").count}"
puts "="*60
