namespace :scan do

	desc "Scan all sites"
	task(:sites => :environment) do

		Rails.logger.info "Starting to scan sites"
		sites = Site.find_all_by_scanable(true)

		if sites.empty?
		  Rails.logger.info "No sites to scan"
		else
      sites.each do |site|
	      begin
		      site.scan
	      rescue
		      Rails.logger.error "Could not scan site - #{$!}"
	      end
      end
		end
		
		Rails.logger.info "Finished scanning sites"
	end

end
