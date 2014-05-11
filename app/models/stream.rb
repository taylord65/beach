class Stream < ActiveRecord::Base
  has_many :videos
  validates :title, :description, :presence => true
  validates :title, :uniqueness => true
end
