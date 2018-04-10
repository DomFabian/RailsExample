User.create!(name:  "Example User",
             email: "example@email.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now )


#99.times do |n|
# name  = Faker::Name.name
#  email = "example-#{n+1}@email.org"
#  password = "password"
#  User.create!(name:  name,
#               email: email,
#               password:              password,
#               password_confirmation: password
#               admin: false,
#               activated: true,
#               activated_at: Time.zone.now )
#end

# this section commented to avoid other users appearing