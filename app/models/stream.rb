class Stream < ActiveRecord::Base
  has_many :videos, :dependent => :destroy
  has_many :admins, :dependent => :destroy
  has_many :playlists, :dependent => :destroy
  has_many :channels, :dependent => :destroy
  validates :title, :description, :presence => true
  validates :title, :uniqueness => {:case_sensitive => false}
  validates :title, :format => { with: /^[a-zA-Z0-9]*$/ , :multiline => true, :message => 'cannot contain special characters, only letters and numbers.' }
  validates :title, :format => { without: /\s/ , :message => 'cannot have spaces.' }
  
  validates :title, length: {in: 2..20, :message => ' must be between 2 and 20 characters.' }
  validates :description, length: {in: 0..400, :message => ' cannot exceed 200 characters.' }
  
  extend FriendlyId
  friendly_id :title
  
  include Tire::Model::Search
  include Tire::Model::Callbacks
    
  def self.search(params)
    tire.search(load: true) do
      query { string params[:query], default_operator: "AND" } if params[:query].present?
    end
  end
  

end
