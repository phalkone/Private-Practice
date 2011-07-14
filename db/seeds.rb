# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

roles = Role.create([{:title => "admin"}, {:title => "doctor"}, {:title => "patient"}])

#Sample user
user = User.create(:first_name => "Tim", :last_name => "Pintens", 
  :email => "tim@air.local", :email_confirmation => "tim@air.local",
  :password => "secret", :password_confirmation => "secret")
user.roles<<roles.first
user.roles<<roles.find_by_title("doctor")
user.update_attribute("confirmed",true)

#Sample pages
pages = Page.create([{ :nested => false, :sequence => 1, :permalink => "dermatologie"}, 
                 { :nested => false, :sequence => 2, :permalink => "behandelingen"}])
pages.first.page_contents.create([{:title => "Dermatologie", :body => "Eerste pagina",
                                  :locale => "nl", :html => false},
                                  {:title => "Dermatology", :body => "First page",
                                   :locale => "en", :html => false}])
pages.last.page_contents.create([{:title => "Behandelingen", :body => "Tweede pagina",
                                  :locale => "nl", :html => false},
                                  {:title => "Treatments", :body => "Seconde page",
                                   :locale => "en", :html => false}])
  
