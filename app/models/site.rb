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
    "data/#{id}"
  end

  def scan
    raise "Cannot scan this site" unless scanable
    URI.parse(resource_url).read.scan(MP3_REGEX).map(&:join).uniq
  end

  def collect
    FileUtils.mkdir_p data_dir

    scan.each do |url|
      song = songs.build(:url => url, :active => false)
      song.download
    end
  end
end
