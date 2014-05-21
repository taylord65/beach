class Stream < ActiveRecord::Base
  has_many :videos
  validates :title, :description, :presence => true
  validates :title, :uniqueness => {:case_sensitive => false}
  validates :title, :format => { without: /\s/ , :message => 'cannot have spaces' }
  
  extend FriendlyId
  friendly_id :title
  
  include Tire::Model::Search
  include Tire::Model::Callbacks
  
  def self.search(params)
    tire.search(load: true) do
      query { string params[:query], default_operator: "AND" } if params[:query].present?
      filter :range, created_at: {lte: Time.zone.now}
    end
  end

end
