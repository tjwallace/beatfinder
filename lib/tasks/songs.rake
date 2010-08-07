namespace :songs do
  
  desc "Download songs"
  task(:download => :environment) do
    Rails.logger.level = Logger::INFO
    Song.where(:active => false).each do |song|
      next if song.has_file?
      begin
        Rails.logger.info "Downloading #{song.id}"
        song.download
        song.import_metadata
        song.active = true
        song.save!
      rescue Exception => ex
        Rails.logger.error ex
      end
    end
  end
  
end
