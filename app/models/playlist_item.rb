class PlaylistItem < ActiveRecord::Base
  belongs_to :song
  belongs_to :playlist, :touch => true
  acts_as_list :scope => :playlist
end
