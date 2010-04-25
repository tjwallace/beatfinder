class Site < ActiveRecord::Base
  MP3_REGEX = /['"](http:\/\/.*?\.mp3)['"]/i

  acts_as_taggable
	
	has_many :songs, :dependent => :destroy

	scope :visible, where(:visible => true)
	scope :scanable, where(:scanable => true)

  validates_presence_of :name, :url, :resource_url
	validates_uniqueness_of :url, :resource_url

  def to_s
    name
  end

	def data_dir
		"data/#{id}"
	end

	def scan
		raise "This site is not scanable" unless scanable

		FileUtils.mkdir_p data_dir unless File.directory? data_dir

		logger.info "Scanning #{name} @ #{resource_url}"
		
    urls = URI.parse(resource_url).read.scan(MP3_REGEX).uniq.map!(&:join)
		urls.each do |url|
			logger.info "Found: \"#{url}\""
			begin
				song = songs.build(:url => url, :active => false)
				song.collect
			rescue Exception => ex
				logger.error ex
			end
		end
	end
end
