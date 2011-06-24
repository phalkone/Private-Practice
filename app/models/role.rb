# == Schema Information
# Schema version: 20110112082837
#
# Table name: roles
#
#  id    :integer         not null, primary key
#  title :string(255)
#

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users
end
