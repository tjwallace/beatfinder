class Song < ActiveRecord::Base
  RECENT_DEFAULT = 20

	belongs_to :site

	scope :recent, lambda { |limit| limit(limit || RECENT_DEFAULT).order("created_at DESC") }
	scope :active, where(:active => true)

	validates_uniqueness_of :url, :file

  before_save :update_tags
	before_destroy :delete_file

	def to_s
	  "#{artist} - #{title}"
	end

	def has_file?
	  !file.nil? && !file_size.nil?
	end

	def delete_file
		if has_file?
			File.unlink(file)
		end
	end

	def update_tags
		if has_file?
			Mp3Info.open(file) do |mp3|
				mp3.tag.title = title unless title.nil?
				mp3.tag.artist = artist unless artist.nil?
			end

			smart_rename
		end
	end

	def file_size
		File.size?(file) unless file.nil?
	end

	def remote_size
		return -1 if url.nil?

		size = -1
		durl = URI.parse(URI.escape(url))
		Net::HTTP.start(durl.host, durl.port) do |http|
			res = http.head(durl.path)
			size = res.content_length unless res.nil?
		end
		size
	end

	def collect
		raise "nil URL" if url.nil?

		# unescape url
		self.url = URI.unescape(url)

		# setup download file
		self.file = File.join(site.data_dir, clean(url.split('/').last))
		self.save!

		# check file size
		rsize = remote_size
		if rsize < 0 || rsize > 20971520
			logger.error "File too big (#{rsize})"
			return false;
		end

		# download file
		Curl::Easy.new(URI.escape(url)) do |curl|
			logger.info "Downloading file to: #{self.file}"
			curl.perform
			File.open(self.file, 'w') do |file|
				file.write(curl.body_str)
			end
		end

		# update artist and title info
		Mp3Info.open(self.file) do |mp3|
			self.title = mp3.tag.title || url.split('/').last.gsub(/\.mp3/, '')
			self.title = clean(self.title)
			
			self.artist = mp3.tag.artist || "NA"
			self.artist = clean(self.artist)

			logger.info "Info: #{self.artist} - #{self.title}"
		end
		
		# rename file
		smart_rename
		logger.info "Renaming to: #{self.file}"

		self.active = true;
		self.save!
	end

	private
	
	def clean(input)
		input.gsub(/[^A-Za-z0-9_  \(\)&-\.]/, '').gsub(/  /, ' ').strip
	end

	def clean_for_fn(input)
		clean(input).gsub(/ /, '_').downcase
	end

	def smart_rename
		old_file = self.file
		self.file = File.join(site.data_dir, "#{clean_for_fn(self.artist)}_-_#{clean_for_fn(self.title)}.mp3")
		File.rename(old_file, self.file)
	end
end
