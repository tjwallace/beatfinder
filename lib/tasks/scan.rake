namespace :scan do

  desc "Scan all sites"
  task(:sites => :environment) do
    logger = Rails.logger
    logger.info "Starting to scan sites"
    sites = Site.scanable

    if sites.empty?
      logger.info "No sites to scan"
    else
      sites.each do |site|
        site.scan.each do |url|
          puts url
        end
      end
    end
    
    logger.info "Finished scanning sites"
  end

  desc "Collect all sites"
  task(:collect => :environment) do
    Rails.logger.level = Logger::INFO
    Site.scanable.map(&:collect)
  end

end
