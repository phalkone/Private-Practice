namespace :db do 
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    User.create!(:first_name => "Example", :last_name => "User", :email => "example@user.com",
    :email_confirmation => "example@user.com", :password => "foobar",:password_confirmation => "foobar")
    99.times do |n|
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      email = "example-#{n+1}@user.com"
      password = "password"
      User.create!(:first_name => first_name, :last_name => last_name,
        :email => email, :email_confirmation =>email, 
        :password => password, :password_confirmation => password)
    end
  end
end