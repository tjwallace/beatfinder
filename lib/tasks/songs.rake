namespace :songs do
  
  desc "Download songs"
  task(:download => :environment) do
    Rails.logger.level = Logger::INFO
    Song.where(:active => false).each do |song|
      continue if song.has_file?
      song.download
      song.import_metadata
      song.active = true
      song.save
    end
  end
  
end