class PlaylistItem < ActiveRecord::Base
  belongs_to :song
  belongs_to :playlist, :touch => true
  acts_as_list :scope => :playlist

  def css_selector
    "#playlist_item_#{id}"
  end
end
