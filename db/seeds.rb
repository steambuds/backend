# frozen_string_literal: true

# Clear existing data
puts "\n" + "="*60
puts "STEAM BUDS - Database Seeding"
puts "="*60

puts "\nCleaning database..."
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
    roles: roles
  )

  Profile.create!(
    id: user.id,
    name: username,
    steamer_id: 9000000 + User.count,
    bio: profile_data[:bio] || "Profile for #{username}",
    gender: profile_data[:gender],
    date_of_birth: profile_data[:date_of_birth],
    father_name: profile_data[:father_name],
    mother_name: profile_data[:mother_name],
    roll_specific_detail: profile_data[:roll_specific_detail]
  )

  puts "  ✓ #{username.ljust(25)} | #{roles.map(&:to_s).join(', ').ljust(15)}"
  user
end

puts "\n=== Creating 20 Users ==="
puts "  " + "-"*58

# 1. Admin (1 user)
admin = create_user("Ghanshyam", [:admin], {
  bio: "System Administrator - STEAM Buds Platform",
  gender: "male",
  date_of_birth: Date.new(1985, 5, 15)
})

# 2. Teachers/Instructors (2 users)
teacher1 = create_user("Priya Sharma", [:instructor], {
  roll_specific_detail: {
    qualification: "B.Ed in Mathematics, M.Sc Mathematics",
    years_of_experience: 5,
    subjects: ["Mathematics", "Physics", "Computer Science"]
  },
  bio: "Mathematics Teacher - Greenwood Public School",
  gender: "female",
  date_of_birth: Date.new(1990, 3, 20)
})

teacher2 = create_user("Rajesh Kumar", [:instructor], {
  roll_specific_detail: {
    qualification: "M.Sc in Biology, B.Ed",
    years_of_experience: 8,
    subjects: ["Biology", "Chemistry", "Environmental Science"]
  },
  bio: "Science Teacher - Sunnydale High School",
  gender: "male",
  date_of_birth: Date.new(1987, 7, 10)
})

# 3. Facilitators (2 users)
facilitator1 = create_user("Anjali Verma", [:facilitator], {
  bio: "Community Facilitator - STEAM Program Coordinator",
  gender: "female",
  date_of_birth: Date.new(1992, 9, 5)
})

facilitator2 = create_user("Vikram Singh", [:facilitator], {
  bio: "Field Facilitator - Student Support Specialist",
  gender: "male",
  date_of_birth: Date.new(1988, 11, 25)
})

# 4. Guardians/Parents (2 users - no specific roles)
guardian1 = create_user("Ramesh Patel", [], {
  bio: "Parent/Guardian of Aarav Patel",
  gender: "male",
  date_of_birth: Date.new(1975, 4, 12)
})

guardian2 = create_user("Sunita Reddy", [], {
  bio: "Parent/Guardian of Diya Reddy",
  gender: "female",
  date_of_birth: Date.new(1978, 8, 18)
})

# 5. Students (14 users)
student_data = [
  { name: "Aarav Patel", gender: "male", grade: "9", section: "A", dob: Date.new(2010, 1, 15), father: "Ramesh Patel", mother: "Seema Patel" },
  { name: "Diya Reddy", gender: "female", grade: "9", section: "A", dob: Date.new(2010, 2, 20), father: "Venkat Reddy", mother: "Sunita Reddy" },
  { name: "Arjun Mehta", gender: "male", grade: "9", section: "B", dob: Date.new(2010, 3, 10), father: "Kiran Mehta", mother: "Neha Mehta" },
  { name: "Ishita Gupta", gender: "female", grade: "9", section: "B", dob: Date.new(2010, 4, 5), father: "Suresh Gupta", mother: "Kavita Gupta" },
  { name: "Rohan Das", gender: "male", grade: "10", section: "A", dob: Date.new(2009, 5, 12), father: "Amit Das", mother: "Priya Das" },
  { name: "Sneha Iyer", gender: "female", grade: "10", section: "A", dob: Date.new(2009, 6, 8), father: "Ravi Iyer", mother: "Lakshmi Iyer" },
  { name: "Kabir Joshi", gender: "male", grade: "10", section: "B", dob: Date.new(2009, 7, 22), father: "Deepak Joshi", mother: "Anjali Joshi" },
  { name: "Ananya Nair", gender: "female", grade: "10", section: "B", dob: Date.new(2009, 8, 30), father: "Sunil Nair", mother: "Maya Nair" },
  { name: "Aditya Singh", gender: "male", grade: "9", section: "C", dob: Date.new(2010, 9, 14), father: "Rajendra Singh", mother: "Pooja Singh" },
  { name: "Meera Desai", gender: "female", grade: "9", section: "C", dob: Date.new(2010, 10, 3), father: "Nitin Desai", mother: "Swati Desai" },
  { name: "Karan Malhotra", gender: "male", grade: "10", section: "C", dob: Date.new(2009, 11, 18), father: "Vinod Malhotra", mother: "Ritu Malhotra" },
  { name: "Pooja Sharma", gender: "female", grade: "10", section: "C", dob: Date.new(2009, 12, 25), father: "Anil Sharma", mother: "Rekha Sharma" },
  { name: "Vihan Kapoor", gender: "male", grade: "9", section: "A", dob: Date.new(2010, 1, 8), father: "Manish Kapoor", mother: "Divya Kapoor" },
  { name: "Riya Bansal", gender: "female", grade: "10", section: "A", dob: Date.new(2009, 2, 16), father: "Sanjay Bansal", mother: "Nisha Bansal" }
]

students = student_data.map do |s|
  create_user(s[:name], [:student], {
    roll_specific_detail: {
      grade: s[:grade],
      section: s[:section],
      roll_number: rand(1..50),
      enrollment_date: Date.today - rand(365..730).days
    },
    gender: s[:gender],
    date_of_birth: s[:dob],
    father_name: s[:father],
    mother_name: s[:mother]
  })
end

puts "\n=== Creating 3 Schools ==="

school1 = School.create!(
  steamer_id: 1001,
  school_name: "Greenwood Public School",
  district: "North Mumbai",
  city_village: "Andheri",
  pincode: 400053,
  address: "123 MG Road, Andheri West",
  landmark: "Near Andheri Metro Station",
  created_by: admin.id,
  updated_by: admin.id
)
puts "  ✓ #{school1.school_name} - #{school1.city_village}"

school2 = School.create!(
  steamer_id: 1002,
  school_name: "Sunnydale High School",
  district: "South Mumbai",
  city_village: "Bandra",
  pincode: 400050,
  address: "456 Linking Road, Bandra West",
  landmark: "Opposite Bandra Court",
  created_by: admin.id,
  updated_by: admin.id
)
puts "  ✓ #{school2.school_name} - #{school2.city_village}"

school3 = School.create!(
  steamer_id: 1003,
  school_name: "Riverside Academy",
  district: "West Mumbai",
  city_village: "Goregaon",
  pincode: 400062,
  address: "789 SV Road, Goregaon East",
  landmark: "Near Film City",
  created_by: admin.id,
  updated_by: admin.id
)
puts "  ✓ #{school3.school_name} - #{school3.city_village}"

puts "\n=== Assigning Users to Schools ==="

# Teachers
SchoolUser.create!(school: school1, user: teacher1, relation: :instructor, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{teacher1.profile.name} → #{school1.school_name} (Instructor)"

SchoolUser.create!(school: school2, user: teacher2, relation: :instructor, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{teacher2.profile.name} → #{school2.school_name} (Instructor)"

# Facilitators
SchoolUser.create!(school: school1, user: facilitator1, relation: :facilitator, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{facilitator1.profile.name} → #{school1.school_name} (Facilitator)"

SchoolUser.create!(school: school3, user: facilitator2, relation: :facilitator, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{facilitator2.profile.name} → #{school3.school_name} (Facilitator)"

# Students distribution: School1 (6), School2 (5), School3 (3)
school1_students = students[0..5]
school2_students = students[6..10]
school3_students = students[11..13]

puts "\n  School 1 (#{school1.school_name}):"
school1_students.each do |student|
  SchoolUser.create!(school: school1, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
  puts "    • #{student.profile.name}"
end

puts "\n  School 2 (#{school2.school_name}):"
school2_students.each do |student|
  SchoolUser.create!(school: school2, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
  puts "    • #{student.profile.name}"
end

puts "\n  School 3 (#{school3.school_name}):"
school3_students.each do |student|
  SchoolUser.create!(school: school3, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
  puts "    • #{student.profile.name}"
end

puts "\n=== Creating 3 Groups ==="

# GROUP 1: All students from SAME school (Greenwood - School 1)
group1 = Group.create!(
  name: "Greenwood Math Champions",
  about: "Advanced Mathematics and Problem Solving - All students from Greenwood Public School",
  grades: "9,10",
  same_school: true,
  created_by: admin.id,
  updated_by: admin.id
)

GroupUser.create!(group: group1, user: teacher1, relation: :instructor, created_by: admin.id, updated_by: admin.id)
school1_students.each do |student|
  GroupUser.create!(group: group1, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end

puts "\n  📚 Group 1: #{group1.name}"
puts "     Same School: YES (#{school1.school_name})"
puts "     Instructor:  #{teacher1.profile.name}"
puts "     Students:    #{school1_students.count} (all from #{school1.school_name})"

# GROUP 2: Students from DIFFERENT schools (Inter-school collaboration)
group2 = Group.create!(
  name: "Inter-School Science Explorers",
  about: "Multi-school collaborative STEAM projects - Students from 3 different schools",
  grades: "9,10",
  same_school: false,
  created_by: admin.id,
  updated_by: admin.id
)

GroupUser.create!(group: group2, user: teacher2, relation: :instructor, created_by: admin.id, updated_by: admin.id)
GroupUser.create!(group: group2, user: facilitator1, relation: :facilitator, created_by: admin.id, updated_by: admin.id)

# Mix: 3 from School 1, 3 from School 2, 2 from School 3
mixed_students = [
  students[0], students[2], students[4],   # School 1: Aarav, Arjun, Rohan
  students[6], students[7], students[9],   # School 2: Kabir, Ananya, Meera
  students[11], students[12]               # School 3: Karan, Pooja
]
mixed_students.each do |student|
  GroupUser.create!(group: group2, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end

puts "\n  🔬 Group 2: #{group2.name}"
puts "     Same School: NO (Mixed schools)"
puts "     Instructor:  #{teacher2.profile.name}"
puts "     Facilitator: #{facilitator1.profile.name}"
puts "     Students:    #{mixed_students.count} (3 from School1, 3 from School2, 2 from School3)"

# GROUP 3: Community/Weekend group (Facilitator-led, any type)
group3 = Group.create!(
  name: "Weekend STEAM Club",
  about: "Weekend enrichment program - Art, Robotics, and Creative Thinking for all",
  grades: "9,10,All",
  same_school: false,
  created_by: admin.id,
  updated_by: admin.id
)

GroupUser.create!(group: group3, user: facilitator2, relation: :facilitator, created_by: admin.id, updated_by: admin.id)

# Random selection: 6 students from various schools
group3_students = [students[1], students[3], students[5], students[8], students[10], students[13]]
group3_students.each do |student|
  GroupUser.create!(group: group3, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end

puts "\n  🎨 Group 3: #{group3.name}"
puts "     Same School: NO (Community-based)"
puts "     Facilitator: #{facilitator2.profile.name}"
puts "     Students:    #{group3_students.count} (mixed schools)"

puts "\n=== Creating Attendance Records (Past 30 Days) ==="

# Define some student patterns for realistic attendance
always_present = [students[0], students[4], students[6]]      # Aarav, Rohan, Kabir
often_late = [students[2], students[7]]                       # Arjun, Ananya (late on Mondays)
recently_excused = [students[5], students[10]]                # Sneha, Meera (excused last 2 weeks)
occasional_absent = [students[3], students[8], students[11]]  # Ishita, Aditya, Karan

dates = (0..29).map { |i| Date.today - i.days }
total_attendance = 0

[group1, group2, group3].each_with_index do |group, idx|
  group_students = group.users.joins(:group_users)
                        .where(group_users: { relation: 'student', group_id: group.id })
                        .distinct

  instructor = group.users.joins(:group_users)
                    .where(group_users: { relation: ['instructor', 'facilitator'], group_id: group.id })
                    .first

  group_attendance_count = 0

  dates.each_with_index do |date, day_idx|
    # Skip weekends
    next if date.saturday? || date.sunday?

    group_students.each do |student|
      # Determine attendance status based on patterns
      status = if always_present.include?(student)
        :present
      elsif often_late.include?(student) && date.monday?
        :late
      elsif recently_excused.include?(student) && day_idx < 14
        :excused
      elsif occasional_absent.include?(student) && rand(100) < 15
        :absent
      else
        # Random distribution: 85% present, 7% late, 5% excused, 3% absent
        rand_val = rand(100)
        if rand_val < 85
          :present
        elsif rand_val < 92
          :late
        elsif rand_val < 97
          :excused
        else
          :absent
        end
      end

      Attendance.create!(
        group: group,
        user: student,
        attendance_at: date.to_time.change(hour: 9, min: 0, sec: 0),
        status: status,
        created_by: instructor&.id || admin.id,
        updated_by: instructor&.id || admin.id
      )
      group_attendance_count += 1
    end
  end

  total_attendance += group_attendance_count

  # Calculate stats
  weekdays = dates.count { |d| !d.saturday? && !d.sunday? }
  puts "\n  Group #{idx + 1} (#{group.name}):"
  puts "    Students:  #{group_students.count}"
  puts "    Weekdays:  #{weekdays}"
  puts "    Records:   #{group_attendance_count}"
end

puts "\n" + "="*60
puts "✅ SEEDING COMPLETED SUCCESSFULLY!"
puts "="*60

puts "\n📊 DATABASE SUMMARY:"
puts "  Users:       #{User.count} total"
puts "    - Admin:         1"
puts "    - Instructors:   2"
puts "    - Facilitators:  2"
puts "    - Guardians:     2"
puts "    - Students:      14"
puts "  Schools:     #{School.count}"
puts "  Groups:      #{Group.count}"
puts "  Attendance:  #{Attendance.count} records"

puts "\n🔑 LOGIN CREDENTIALS (Password: Password123):"
puts "  Admin:         #{admin.email}"
puts "  Teacher 1:     #{teacher1.email}"
puts "  Teacher 2:     #{teacher2.email}"
puts "  Facilitator 1: #{facilitator1.email}"
puts "  Facilitator 2: #{facilitator2.email}"

puts "\n📋 GROUP BREAKDOWN:"
puts "  Group 1: #{group1.name}"
puts "    → Same school only (Greenwood Public School)"
puts "    → 6 students, 1 instructor"
puts ""
puts "  Group 2: #{group2.name}"
puts "    → Multi-school (3 schools mixed)"
puts "    → 8 students, 1 instructor, 1 facilitator"
puts ""
puts "  Group 3: #{group3.name}"
puts "    → Community/weekend program"
puts "    → 6 students, 1 facilitator"

puts "\n💡 ATTENDANCE PATTERNS:"
puts "  Always Present:    #{always_present.map { |s| s.profile.name }.join(', ')}"
puts "  Often Late:        #{often_late.map { |s| s.profile.name }.join(', ')}"
puts "  Recently Excused:  #{recently_excused.map { |s| s.profile.name }.join(', ')}"
puts "  Occasional Absent: #{occasional_absent.map { |s| s.profile.name }.join(', ')}"

puts "\n" + "="*60
puts "Ready for Attendance UI Testing! 🚀"
puts "="*60
puts ""
