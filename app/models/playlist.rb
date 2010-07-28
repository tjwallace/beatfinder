class Playlist < ActiveRecord::Base
  belongs_to :user
  has_many :playlist_items, :order => "position ASC", :include => :song
  has_many :songs, :through => :playlist_items, :order => "position ASC"

  def anonymous?
    self.user.nil?
  end
end
