Factory.define :user do |user|
  user.first_name             "Test"
  user.last_name              "User"
  user.email                  "test@user.com"
  user.password               "secret"
  user.password_confirmation  "secret"
end