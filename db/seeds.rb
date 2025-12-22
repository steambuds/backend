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

puts "\n=== Creating 50 Users ==="
puts "  " + "-"*58

# 1. Admin (1 user)
admin = create_user("Ghanshyam", [ :admin ], {
  bio: "System Administrator - STEAM Buds Platform",
  gender: "male",
  date_of_birth: Date.new(1985, 5, 15)
})

# 2. Teachers (4 users)
teacher1 = create_user("Priya Sharma", [ :teacher ], {
  roll_specific_detail: {
    teacher: {
      qualification: "B.Ed in Mathematics, M.Sc Mathematics",
      years_of_experience: 5,
      subjects: [ "Mathematics", "Physics", "Computer Science" ]
    }
  },
  bio: "Senior Mathematics Teacher - Manages multiple STEAM groups",
  gender: "female",
  date_of_birth: Date.new(1990, 3, 20)
})

teacher2 = create_user("Rajesh Kumar", [ :teacher ], {
  roll_specific_detail: {
    teacher: {
      qualification: "M.Sc in Biology, B.Ed",
      years_of_experience: 8,
      subjects: [ "Biology", "Chemistry", "Environmental Science" ]
    }
  },
  bio: "Science Teacher - Sunnydale High School",
  gender: "male",
  date_of_birth: Date.new(1987, 7, 10)
})

teacher3 = create_user("Meera Iyer", [ :teacher ], {
  roll_specific_detail: {
    teacher: {
      qualification: "B.Tech Computer Science, M.Ed",
      years_of_experience: 6,
      subjects: [ "Computer Science", "Robotics", "AI & ML" ]
    }
  },
  bio: "Technology & Innovation Teacher",
  gender: "female",
  date_of_birth: Date.new(1989, 6, 15)
})

teacher4 = create_user("Amit Patel", [ :teacher ], {
  roll_specific_detail: {
    teacher: {
      qualification: "M.Sc Physics, B.Ed",
      years_of_experience: 10,
      subjects: [ "Physics", "Mathematics", "Engineering Design" ]
    }
  },
  bio: "Senior Physics Teacher & STEAM Coordinator",
  gender: "male",
  date_of_birth: Date.new(1985, 11, 8)
})

# 3. Facilitators (converted to Teachers) (3 users)
facilitator1 = create_user("Anjali Verma", [ :teacher ], {
  bio: "Community Facilitator - STEAM Program Coordinator",
  gender: "female",
  date_of_birth: Date.new(1992, 9, 5)
})

facilitator2 = create_user("Vikram Singh", [ :teacher ], {
  bio: "Field Facilitator - Student Support Specialist",
  gender: "male",
  date_of_birth: Date.new(1988, 11, 25)
})

facilitator3 = create_user("Kavita Deshmukh", [ :teacher ], {
  bio: "Program Facilitator - Group Activities Coordinator",
  gender: "female",
  date_of_birth: Date.new(1991, 4, 18)
})

# 4. Students (45 users)
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
  { name: "Riya Bansal", gender: "female", grade: "10", section: "A", dob: Date.new(2009, 2, 16), father: "Sanjay Bansal", mother: "Nisha Bansal" },
  { name: "Sahil Chopra", gender: "male", grade: "9", section: "B", dob: Date.new(2010, 3, 22), father: "Rajiv Chopra", mother: "Simran Chopra" },
  { name: "Tanvi Kulkarni", gender: "female", grade: "9", section: "C", dob: Date.new(2010, 4, 11), father: "Prakash Kulkarni", mother: "Vandana Kulkarni" },
  { name: "Yash Agarwal", gender: "male", grade: "10", section: "B", dob: Date.new(2009, 5, 19), father: "Manoj Agarwal", mother: "Renu Agarwal" },
  { name: "Naina Saxena", gender: "female", grade: "10", section: "C", dob: Date.new(2009, 6, 27), father: "Vikas Saxena", mother: "Geeta Saxena" },
  { name: "Dhruv Mishra", gender: "male", grade: "9", section: "A", dob: Date.new(2010, 7, 5), father: "Santosh Mishra", mother: "Anjali Mishra" },
  { name: "Isha Khanna", gender: "female", grade: "9", section: "B", dob: Date.new(2010, 8, 13), father: "Rahul Khanna", mother: "Priya Khanna" },
  { name: "Atharv Jain", gender: "male", grade: "10", section: "A", dob: Date.new(2009, 9, 21), father: "Nikhil Jain", mother: "Sonia Jain" },
  { name: "Aditi Rao", gender: "female", grade: "10", section: "B", dob: Date.new(2009, 10, 29), father: "Suresh Rao", mother: "Madhuri Rao" },
  { name: "Aryan Bose", gender: "male", grade: "9", section: "C", dob: Date.new(2010, 11, 6), father: "Debashish Bose", mother: "Rina Bose" },
  { name: "Sanya Bhatt", gender: "female", grade: "9", section: "A", dob: Date.new(2010, 12, 14), father: "Arun Bhatt", mother: "Sunita Bhatt" },
  { name: "Vivaan Shah", gender: "male", grade: "10", section: "C", dob: Date.new(2009, 1, 22), father: "Ketan Shah", mother: "Hina Shah" },
  { name: "Kiara Pillai", gender: "female", grade: "10", section: "A", dob: Date.new(2009, 2, 28), father: "Vinay Pillai", mother: "Lakshmi Pillai" },
  { name: "Reyansh Pandey", gender: "male", grade: "9", section: "B", dob: Date.new(2010, 3, 7), father: "Ashok Pandey", mother: "Meena Pandey" },
  { name: "Aadhya Menon", gender: "female", grade: "9", section: "C", dob: Date.new(2010, 4, 15), father: "Krishna Menon", mother: "Radha Menon" },
  { name: "Pranav Sinha", gender: "male", grade: "10", section: "B", dob: Date.new(2009, 5, 23), father: "Rajesh Sinha", mother: "Kavita Sinha" },
  { name: "Myra Thakur", gender: "female", grade: "10", section: "C", dob: Date.new(2009, 6, 30), father: "Mohit Thakur", mother: "Shweta Thakur" },
  { name: "Shivansh Arora", gender: "male", grade: "9", section: "A", dob: Date.new(2010, 7, 8), father: "Deepak Arora", mother: "Neelam Arora" },
  { name: "Avni Bajaj", gender: "female", grade: "9", section: "B", dob: Date.new(2010, 8, 16), father: "Sanjay Bajaj", mother: "Pooja Bajaj" },
  { name: "Arnav Ghosh", gender: "male", grade: "10", section: "A", dob: Date.new(2009, 9, 24), father: "Subrata Ghosh", mother: "Dipti Ghosh" },
  { name: "Saanvi Reddy", gender: "female", grade: "10", section: "B", dob: Date.new(2009, 10, 2), father: "Ramesh Reddy", mother: "Priya Reddy" },
  { name: "Ayaan Khan", gender: "male", grade: "9", section: "C", dob: Date.new(2010, 11, 10), father: "Aamir Khan", mother: "Fatima Khan" },
  { name: "Pari Varma", gender: "female", grade: "9", section: "A", dob: Date.new(2010, 12, 18), father: "Ajay Varma", mother: "Nisha Varma" },
  { name: "Shaurya Tiwari", gender: "male", grade: "10", section: "C", dob: Date.new(2009, 1, 26), father: "Pankaj Tiwari", mother: "Rekha Tiwari" },
  { name: "Anvi Dubey", gender: "female", grade: "10", section: "A", dob: Date.new(2009, 2, 3), father: "Alok Dubey", mother: "Preeti Dubey" },
  { name: "Veer Chauhan", gender: "male", grade: "9", section: "B", dob: Date.new(2010, 3, 12), father: "Vijay Chauhan", mother: "Anjana Chauhan" },
  { name: "Navya Yadav", gender: "female", grade: "9", section: "C", dob: Date.new(2010, 4, 20), father: "Sunil Yadav", mother: "Mamta Yadav" },
  { name: "Aayush Singh", gender: "male", grade: "10", section: "B", dob: Date.new(2009, 5, 28), father: "Dinesh Singh", mother: "Sunita Singh" },
  { name: "Zara Ali", gender: "female", grade: "10", section: "C", dob: Date.new(2009, 6, 5), father: "Ahmed Ali", mother: "Nargis Ali" },
  { name: "Kabir Malhotra", gender: "male", grade: "9", section: "A", dob: Date.new(2010, 7, 13), father: "Rohit Malhotra", mother: "Shalini Malhotra" },
  { name: "Ira Kapoor", gender: "female", grade: "9", section: "B", dob: Date.new(2010, 8, 21), father: "Kunal Kapoor", mother: "Tanvi Kapoor" },
  { name: "Rudra Joshi", gender: "male", grade: "10", section: "A", dob: Date.new(2009, 9, 29), father: "Manoj Joshi", mother: "Seema Joshi" }
]

students = student_data.map do |s|
  create_user(s[:name], [ :student ], {
    roll_specific_detail: {
      student: {
        grade: s[:grade],
        section: s[:section],
        roll_number: rand(1..50),
        enrollment_date: Date.today - rand(365..730).days
      }
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
SchoolUser.create!(school: school1, user: teacher1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{teacher1.profile.name} → #{school1.school_name} (Teacher)"

SchoolUser.create!(school: school2, user: teacher2, relation: :teacher, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{teacher2.profile.name} → #{school2.school_name} (Teacher)"

SchoolUser.create!(school: school1, user: teacher3, relation: :teacher, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{teacher3.profile.name} → #{school1.school_name} (Teacher)"

SchoolUser.create!(school: school3, user: teacher4, relation: :teacher, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{teacher4.profile.name} → #{school3.school_name} (Teacher)"

# Facilitators (now Teachers)
SchoolUser.create!(school: school1, user: facilitator1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{facilitator1.profile.name} → #{school1.school_name} (Teacher)"

SchoolUser.create!(school: school2, user: facilitator2, relation: :teacher, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{facilitator2.profile.name} → #{school2.school_name} (Teacher)"

SchoolUser.create!(school: school3, user: facilitator3, relation: :teacher, created_by: admin.id, updated_by: admin.id)
puts "  ✓ #{facilitator3.profile.name} → #{school3.school_name} (Teacher)"

# Students distribution: School1 (15), School2 (15), School3 (15)
school1_students = students[0..14]
school2_students = students[15..29]
school3_students = students[30..44]

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

puts "\n=== Creating 9 Groups ==="

# Teacher1 (Priya Sharma) manages 5 groups
# GROUP 1: Math Champions - Grade 9
group1 = Group.create!(
  name: "Math Champions - Grade 9A",
  about: "Advanced Mathematics and Problem Solving for Grade 9 students",
  grades: "9",
  same_school: true,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(group: group1, user: teacher1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
GroupUser.create!(group: group1, user: facilitator1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
[ students[0], students[2], students[8], students[12], students[18] ].each do |student|
  GroupUser.create!(group: group1, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end
puts "  📚 Group 1: #{group1.name} (Teachers: #{teacher1.profile.name}, #{facilitator1.profile.name}, Students: 5)"

# GROUP 2: Physics Lab - Grade 10
group2 = Group.create!(
  name: "Physics Lab - Grade 10A",
  about: "Experimental Physics and Hands-on Projects for Grade 10",
  grades: "10",
  same_school: true,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(group: group2, user: teacher1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
GroupUser.create!(group: group2, user: facilitator1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
[ students[4], students[5], students[6], students[10], students[16], students[20] ].each do |student|
  GroupUser.create!(group: group2, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end
puts "  🔬 Group 2: #{group2.name} (Teachers: #{teacher1.profile.name}, #{facilitator1.profile.name}, Students: 6)"

# GROUP 3: Computer Science Basics
group3 = Group.create!(
  name: "Computer Science Fundamentals",
  about: "Introduction to Programming and Computational Thinking",
  grades: "9,10",
  same_school: false,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(group: group3, user: teacher1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
GroupUser.create!(group: group3, user: facilitator1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
[ students[1], students[7], students[14], students[21], students[28] ].each do |student|
  GroupUser.create!(group: group3, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end
puts "  💻 Group 3: #{group3.name} (Teachers: #{teacher1.profile.name}, #{facilitator1.profile.name}, Students: 5)"

# GROUP 4: Algebra & Geometry
group4 = Group.create!(
  name: "Algebra & Geometry Workshop",
  about: "Deep dive into Algebraic structures and Geometric proofs",
  grades: "9",
  same_school: true,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(group: group4, user: teacher1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
GroupUser.create!(group: group4, user: facilitator1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
[ students[3], students[9], students[15], students[22] ].each do |student|
  GroupUser.create!(group: group4, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end
puts "  📐 Group 4: #{group4.name} (Teachers: #{teacher1.profile.name}, #{facilitator1.profile.name}, Students: 4)"

# GROUP 5: STEAM Integration
group5 = Group.create!(
  name: "STEAM Integration Lab",
  about: "Cross-disciplinary projects combining Science, Tech, Engineering, Art & Math",
  grades: "9,10",
  same_school: false,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(group: group5, user: teacher1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
GroupUser.create!(group: group5, user: facilitator1, relation: :teacher, created_by: admin.id, updated_by: admin.id)
[ students[11], students[17], students[23], students[29], students[35], students[40] ].each do |student|
  GroupUser.create!(group: group5, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end
puts "  🎨 Group 5: #{group5.name} (Teachers: #{teacher1.profile.name}, #{facilitator1.profile.name}, Students: 6)"

# GROUP 6: Biology Explorers (Teacher2)
group6 = Group.create!(
  name: "Biology Explorers - Grade 10",
  about: "Ecological studies and Biological research projects",
  grades: "10",
  same_school: true,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(group: group6, user: teacher2, relation: :teacher, created_by: admin.id, updated_by: admin.id)
[ students[13], students[19], students[24], students[30] ].each do |student|
  GroupUser.create!(group: group6, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end
puts "  🧬 Group 6: #{group6.name} (Teacher: #{teacher2.profile.name}, Students: 4)"

# GROUP 7: Robotics & AI (Teacher3)
group7 = Group.create!(
  name: "Robotics & Artificial Intelligence",
  about: "Building robots and exploring AI concepts",
  grades: "9,10",
  same_school: false,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(group: group7, user: teacher3, relation: :teacher, created_by: admin.id, updated_by: admin.id)
GroupUser.create!(group: group7, user: facilitator2, relation: :teacher, created_by: admin.id, updated_by: admin.id)
[ students[25], students[31], students[36], students[41], students[42] ].each do |student|
  GroupUser.create!(group: group7, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end
puts "  🤖 Group 7: #{group7.name} (Teachers: #{teacher3.profile.name}, #{facilitator2.profile.name}, Students: 5)"

# GROUP 8: Engineering Design (Teacher4)
group8 = Group.create!(
  name: "Engineering Design Studio",
  about: "Practical engineering challenges and design thinking",
  grades: "10",
  same_school: true,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(group: group8, user: teacher4, relation: :teacher, created_by: admin.id, updated_by: admin.id)
[ students[26], students[32], students[37], students[43] ].each do |student|
  GroupUser.create!(group: group8, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end
puts "  ⚙️  Group 8: #{group8.name} (Teacher: #{teacher4.profile.name}, Students: 4)"

# GROUP 9: Creative Arts & Science (Facilitator3-led)
group9 = Group.create!(
  name: "Creative Arts & Science Fusion",
  about: "Weekend program blending artistic expression with scientific inquiry",
  grades: "9,10",
  same_school: false,
  created_by: admin.id,
  updated_by: admin.id
)
GroupUser.create!(group: group9, user: facilitator3, relation: :teacher, created_by: admin.id, updated_by: admin.id)
[ students[27], students[33], students[38], students[39], students[44] ].each do |student|
  GroupUser.create!(group: group9, user: student, relation: :student, created_by: admin.id, updated_by: admin.id)
end
puts "  🎭 Group 9: #{group9.name} (Teacher: #{facilitator3.profile.name}, Students: 5)"

puts "\n=== Creating Attendance Records ==="

# Define some student patterns for realistic attendance
always_present = [ students[0], students[4], students[6], students[12], students[18] ]
often_late = [ students[2], students[7], students[14] ]
recently_excused = [ students[5], students[10], students[16] ]
occasional_absent = [ students[3], students[8], students[11], students[15] ]

all_groups = [ group1, group2, group3, group4, group5, group6, group7, group8, group9 ]

# Group 2 (Physics Lab) - 15 specific sessions over past 8 weeks (at least 10 sessions)
puts "\n  Creating detailed attendance for Group 2 (Physics Lab) - 15 sessions:"
group2_students = group2.users.joins(:group_users)
                      .where(group_users: { relation: 'student', group_id: group2.id })
                      .distinct

# Define 15 specific session dates (Mon & Wed for last 8 weeks)
session_dates = []
current_date = Date.today
weeks_back = 0
while session_dates.length < 15 && weeks_back < 12
  check_date = current_date - (weeks_back * 7).days
  # Add Monday session
  monday = check_date - check_date.wday.days + 1.day
  session_dates << monday if monday <= Date.today && monday > Date.today - 60.days
  # Add Wednesday session
  wednesday = monday + 2.days
  session_dates << wednesday if wednesday <= Date.today && wednesday > Date.today - 60.days
  weeks_back += 1
end
session_dates = session_dates.sort.reverse.take(15)

session_count = 0
session_dates.each_with_index do |session_date, idx|
  group2_students.each do |student|
    # More realistic patterns for this important group
    status = if always_present.include?(student)
      :present
    elsif often_late.include?(student) && idx % 3 == 0
      :late
    elsif recently_excused.include?(student) && idx < 3
      :excused
    elsif occasional_absent.include?(student) && idx % 5 == 0
      :absent
    else
      rand_val = rand(100)
      if rand_val < 88
        :present
      elsif rand_val < 94
        :late
      elsif rand_val < 98
        :excused
      else
        :absent
      end
    end

    Attendance.create!(
      group: group2,
      user: student,
      attendance_at: session_date.to_time.change(hour: 9, min: 30, sec: 0),
      status: status,
      created_by: teacher1.id,
      updated_by: teacher1.id
    )
    session_count += 1
  end
end
puts "    ✓ 15 sessions x #{group2_students.count} students = #{session_count} attendance records"

# Create attendance for other groups (varying amounts - past 30 days)
puts "\n  Creating attendance for remaining groups (past 30 days):"
dates = (0..29).map { |i| Date.today - i.days }
total_attendance = session_count

[ group1, group3, group4, group5, group6, group7, group8, group9 ].each_with_index do |group, idx|
  group_students = group.users.joins(:group_users)
                        .where(group_users: { relation: 'student', group_id: group.id })
                        .distinct

  instructor = group.users.joins(:group_users)
                    .where(group_users: { relation: [ 'teacher' ], group_id: group.id })
                    .first

  group_attendance_count = 0

  # Some groups meet more frequently than others
  session_frequency = case idx
  when 0, 1, 2 then 2  # Groups 1, 3, 4 meet twice a week
  when 3, 4    then 3  # Groups 5, 6 meet three times a week
  else              4  # Groups 7, 8, 9 meet four times a week
  end

  dates.each_with_index do |date, day_idx|
    # Skip weekends
    next if date.saturday? || date.sunday?

    # Skip some days based on session frequency
    next if day_idx % (7 / session_frequency) != 0

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
  weekdays = dates.count { |d| !d.saturday? && !d.sunday? }

  puts "    ✓ #{group.name}: #{group_attendance_count} records"
end

puts "\n" + "="*60
puts "✅ SEEDING COMPLETED SUCCESSFULLY!"
puts "="*60

puts "\n📊 DATABASE SUMMARY:"
puts "  Users:       #{User.count} total"
puts "    - Admin:         1"
puts "    - Teachers:      7"
puts "    - Students:      45"
puts "  Schools:     #{School.count}"
puts "  Groups:      #{Group.count}"
puts "  Attendance:  #{Attendance.count} records"

puts "\n🔑 LOGIN CREDENTIALS (Password: Password123):"
puts "  Admin:         #{admin.email}"
puts "  Teacher 1:     #{teacher1.email} (manages 5 groups)"
puts "  Teacher 2:     #{teacher2.email}"
puts "  Teacher 3:     #{teacher3.email}"
puts "  Teacher 4:     #{teacher4.email}"
puts "  Facilitator 1: #{facilitator1.email}"
puts "  Facilitator 2: #{facilitator2.email}"
puts "  Facilitator 3: #{facilitator3.email}"

puts "\n📋 GROUP BREAKDOWN:"
puts "  Teacher 1 (#{teacher1.profile.name}) manages 5 groups with Facilitator 1:"
puts "    → Group 1: #{group1.name} (5 students)"
puts "    → Group 2: #{group2.name} (6 students) ⭐ 15 attendance sessions"
puts "    → Group 3: #{group3.name} (5 students)"
puts "    → Group 4: #{group4.name} (4 students)"
puts "    → Group 5: #{group5.name} (6 students)"
puts ""
puts "  Other Groups:"
puts "    → Group 6: #{group6.name} (#{teacher2.profile.name}, 4 students)"
puts "    → Group 7: #{group7.name} (#{teacher3.profile.name}, 5 students)"
puts "    → Group 8: #{group8.name} (#{teacher4.profile.name}, 4 students)"
puts "    → Group 9: #{group9.name} (#{facilitator3.profile.name}, 5 students)"