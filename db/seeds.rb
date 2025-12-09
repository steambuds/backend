# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Only seed data in development environment
if Rails.env.development?
  # Clear existing data (optional - comment out if you want to preserve existing data)
  puts "Clearing existing data..."
  UserRole.destroy_all
  Profile.destroy_all
  RefreshToken.destroy_all
  User.destroy_all

  puts "Creating admin user..."
  # Create admin user - ghanshyam
  admin = User.create!(
    username: "ghanshyam",
    email: "ghanshyam@steambuds.com",
    mobile_number: "+919876543210",
    password: "Admin123"
  )

  # Assign admin role
  UserRole.create!(user: admin, role: :admin)

  # Create admin profile
  Profile.create!(
    user: admin,
    user_type: :teacher,
    bio: "Administrator and lead instructor at Steam Buds",
    subjects_taught: "Computer Science, Mathematics, Physics",
    years_experience: 10,
    qualification: "PhD in Computer Science",
    phone: "+919876543210",
    address: "123 Admin Street, Tech City",
    date_of_birth: Date.new(1985, 5, 15)
  )

  puts "Admin user 'ghanshyam' created successfully!"

  puts "Creating teacher users..."
  # Create 2 teacher users
  teachers_data = [
    {
      username: "sarah_johnson",
      email: "sarah.johnson@steambuds.com",
      mobile_number: "+919876543211",
      password: "Teacher123",
      bio: "Passionate about teaching mathematics and helping students excel",
      subjects_taught: "Mathematics, Statistics",
      years_experience: 8,
      qualification: "Masters in Mathematics Education",
      phone: "+919876543211",
      address: "456 Teacher Lane, Education City",
      date_of_birth: Date.new(1988, 3, 20)
    },
    {
      username: "michael_chen",
      email: "michael.chen@steambuds.com",
      mobile_number: "+919876543212",
      password: "Teacher123",
      bio: "Science educator with focus on hands-on learning and experiments",
      subjects_taught: "Physics, Chemistry, Biology",
      years_experience: 5,
      qualification: "Masters in Science Education",
      phone: "+919876543212",
      address: "789 Science Boulevard, Research Park",
      date_of_birth: Date.new(1990, 11, 8)
    }
  ]

  teachers_data.each do |teacher_data|
    user = User.create!(
      username: teacher_data[:username],
      email: teacher_data[:email],
      mobile_number: teacher_data[:mobile_number],
      password: teacher_data[:password]
    )

    # Assign manager role to teachers (they can manage their classes)
    UserRole.create!(user: user, role: :manager)

    Profile.create!(
      user: user,
      user_type: :teacher,
      bio: teacher_data[:bio],
      subjects_taught: teacher_data[:subjects_taught],
      years_experience: teacher_data[:years_experience],
      qualification: teacher_data[:qualification],
      phone: teacher_data[:phone],
      address: teacher_data[:address],
      date_of_birth: teacher_data[:date_of_birth]
    )

    puts "Teacher '#{teacher_data[:username]}' created successfully!"
  end

  puts "Creating student users..."
  # Create 10 student users
  students_data = [
    {
      username: "emma_wilson",
      email: "emma.wilson@student.steambuds.com",
      mobile_number: "+919876543220",
      password: "Student123",
      bio: "Enthusiastic learner interested in mathematics and science",
      grade_level: "10th Grade",
      enrollment_date: Date.new(2023, 9, 1),
      parent_contact: "+919876543221",
      phone: "+919876543220",
      address: "101 Student Street, Learning City",
      date_of_birth: Date.new(2010, 6, 15)
    },
    {
      username: "liam_patel",
      email: "liam.patel@student.steambuds.com",
      mobile_number: "+919876543222",
      password: "Student123",
      bio: "Loves coding and robotics",
      grade_level: "11th Grade",
      enrollment_date: Date.new(2022, 9, 1),
      parent_contact: "+919876543223",
      phone: "+919876543222",
      address: "102 Student Street, Learning City",
      date_of_birth: Date.new(2009, 4, 22)
    },
    {
      username: "olivia_martinez",
      email: "olivia.martinez@student.steambuds.com",
      mobile_number: "+919876543224",
      password: "Student123",
      bio: "Aspiring scientist with passion for chemistry",
      grade_level: "12th Grade",
      enrollment_date: Date.new(2021, 9, 1),
      parent_contact: "+919876543225",
      phone: "+919876543224",
      address: "103 Student Street, Learning City",
      date_of_birth: Date.new(2008, 1, 10)
    },
    {
      username: "noah_anderson",
      email: "noah.anderson@student.steambuds.com",
      mobile_number: "+919876543226",
      password: "Student123",
      bio: "Math enthusiast and competitive programmer",
      grade_level: "11th Grade",
      enrollment_date: Date.new(2022, 9, 1),
      parent_contact: "+919876543227",
      phone: "+919876543226",
      address: "104 Student Street, Learning City",
      date_of_birth: Date.new(2009, 9, 5)
    },
    {
      username: "ava_thompson",
      email: "ava.thompson@student.steambuds.com",
      mobile_number: "+919876543228",
      password: "Student123",
      bio: "Creative thinker interested in arts and technology",
      grade_level: "9th Grade",
      enrollment_date: Date.new(2024, 9, 1),
      parent_contact: "+919876543229",
      phone: "+919876543228",
      address: "105 Student Street, Learning City",
      date_of_birth: Date.new(2011, 7, 18)
    },
    {
      username: "ethan_rodriguez",
      email: "ethan.rodriguez@student.steambuds.com",
      mobile_number: "+919876543230",
      password: "Student123",
      bio: "Sports enthusiast and future engineer",
      grade_level: "10th Grade",
      enrollment_date: Date.new(2023, 9, 1),
      parent_contact: "+919876543231",
      phone: "+919876543230",
      address: "106 Student Street, Learning City",
      date_of_birth: Date.new(2010, 2, 28)
    },
    {
      username: "sophia_lee",
      email: "sophia.lee@student.steambuds.com",
      mobile_number: "+919876543232",
      password: "Student123",
      bio: "Loves reading and biology",
      grade_level: "12th Grade",
      enrollment_date: Date.new(2021, 9, 1),
      parent_contact: "+919876543233",
      phone: "+919876543232",
      address: "107 Student Street, Learning City",
      date_of_birth: Date.new(2008, 12, 3)
    },
    {
      username: "jackson_kim",
      email: "jackson.kim@student.steambuds.com",
      mobile_number: "+919876543234",
      password: "Student123",
      bio: "Curious mind interested in physics and astronomy",
      grade_level: "11th Grade",
      enrollment_date: Date.new(2022, 9, 1),
      parent_contact: "+919876543235",
      phone: "+919876543234",
      address: "108 Student Street, Learning City",
      date_of_birth: Date.new(2009, 8, 14)
    },
    {
      username: "mia_nguyen",
      email: "mia.nguyen@student.steambuds.com",
      mobile_number: "+919876543236",
      password: "Student123",
      bio: "Budding writer and literature lover",
      grade_level: "9th Grade",
      enrollment_date: Date.new(2024, 9, 1),
      parent_contact: "+919876543237",
      phone: "+919876543236",
      address: "109 Student Street, Learning City",
      date_of_birth: Date.new(2011, 3, 25)
    },
    {
      username: "lucas_davis",
      email: "lucas.davis@student.steambuds.com",
      mobile_number: "+919876543238",
      password: "Student123",
      bio: "Tech-savvy student passionate about AI and machine learning",
      grade_level: "12th Grade",
      enrollment_date: Date.new(2021, 9, 1),
      parent_contact: "+919876543239",
      phone: "+919876543238",
      address: "110 Student Street, Learning City",
      date_of_birth: Date.new(2008, 10, 30)
    }
  ]

  students_data.each do |student_data|
    user = User.create!(
      username: student_data[:username],
      email: student_data[:email],
      mobile_number: student_data[:mobile_number],
      password: student_data[:password]
    )

    # Students don't have a specific role in UserRole enum, so we don't create a user_role for them
    # But they have student profile

    Profile.create!(
      user: user,
      user_type: :student,
      bio: student_data[:bio],
      grade_level: student_data[:grade_level],
      enrollment_date: student_data[:enrollment_date],
      parent_contact: student_data[:parent_contact],
      phone: student_data[:phone],
      address: student_data[:address],
      date_of_birth: student_data[:date_of_birth]
    )

    puts "Student '#{student_data[:username]}' created successfully!"
  end

  puts "\n" + "=" * 60
  puts "Seed data created successfully!"
  puts "=" * 60
  puts "\nSummary:"
  puts "  - 1 Admin user (ghanshyam) with admin role"
  puts "  - 2 Teacher users with manager role"
  puts "  - 10 Student users"
  puts "\nTotal users: #{User.count}"
  puts "Total profiles: #{Profile.count}"
  puts "Total user roles: #{UserRole.count}"
  puts "\nLogin credentials for all users:"
  puts "  Admin: ghanshyam / Admin123"
  puts "  Teachers: sarah_johnson, michael_chen / Teacher123"
  puts "  Students: [username] / Student123"
  puts "=" * 60
else
  puts "Skipping seed data - only runs in development environment"
  puts "Current environment: #{Rails.env}"
end
