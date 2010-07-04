class PlaylistItem < ActiveRecord::Base
  belongs_to :song
  belongs_to :playlist, :touch => true
end
