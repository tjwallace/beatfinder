namespace :sites do

  desc "Scan all sites"
  task(:scan => :environment) do
    Rails.logger.level = Logger::INFO
    Site.scanable.each do |site|
      puts "#{site.name} @ #{site.resource_url}:"
      site.song_urls.each do |url|
        puts "* #{url}"
      end
      puts ""
    end
  end

  desc "Collect all sites"
  task(:collect => :environment) do
    Rails.logger.level = Logger::INFO
    Site.scanable.map(&:collect)
  end

end
