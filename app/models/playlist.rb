class Playlist < ActiveRecord::Base
  CURRENT = 'current'

  belongs_to :user
  has_many :items, :class_name => "PlaylistItem", :order => "position ASC", :include => :song
  has_many :songs, :through => :items, :order => "position ASC"

  def anonymous?
    self.user.nil?
  end
end
