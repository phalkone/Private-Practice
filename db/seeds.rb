# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

admin = Role.create(:title => "admin")
doctor = Role.create(:title => "doctor")
patient = Role.create(:title => "patient")
User.create(:first_name => "admin", :last_name => "admin", 
  :email => "admin@admin.com", :email_confirmation => "admin@admin.com",
  :password => "secret", :password_confirmation => "secret",
  :roles => admin )
