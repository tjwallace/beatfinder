module SongsHelper
  def add_to_playlist(text, song, playlist = false)
    playlist_id = if playlist == false
      'current'
    else
      playlist.id
    end
    link_to text, playlist_items_path(:playlist_id => playlist_id, :song_id => song.id), :method => :post, :remote => true
  end
end
