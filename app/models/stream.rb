class Stream < ActiveRecord::Base
  has_many :videos
  validates :title, :description, :presence => true
  validates :title, :uniqueness => {:case_sensitive => false}
  validates :title, :format => { without: /\s/ , :message => 'cannot have spaces' }
  
  extend FriendlyId
  friendly_id :title
  
end
