class Site < ActiveRecord::Base
  MP3_REGEX = /['"](http:\/\/[^"' ]+\.mp3)['"]/i

  has_many :songs, :dependent => :destroy

  scope :visible, where(:visible => true)
  scope :scanable, where(:scanable => true)

  validates_presence_of :name, :url, :resource_url
  validates_uniqueness_of :url, :resource_url

  def to_s
    name
  end

  def data_dir
    Rails.root.join "data/#{id}"
  end

  def song_urls
    URI.parse(resource_url).read.scan(MP3_REGEX).map(&:join).uniq
  end

  def collect
    FileUtils.mkdir_p data_dir

    song_urls.each do |url|
      begin
        songs.create(:url => url, :active => false)
      rescue Exception => ex
        logger.info "Site ##{id} - #{ex}"
      end
    end
  end
end
