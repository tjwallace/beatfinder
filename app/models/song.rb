class Song < ActiveRecord::Base
  MAX_SIZE = 20971520
  RECENT_DEFAULT = 30

  belongs_to :site

  scope :active, where(:active => true)

  validates_uniqueness_of :url

  after_save :save_tags
  before_destroy :delete_file

  def self.recent(limit = RECENT_DEFAULT)
    limit(limit).order("created_at DESC")
  end

  def to_s
    "#{artist} - #{title}"
  end
  
  def file_name
    "#{site.data_dir}/#{id}.mp3"
  end
  
  def file_size
    File.size?(file_name)
  end

  def has_file?
    !file_size.nil?
  end

  def delete_file
    File.delete(file_name) if has_file?
  end

  def remote_size
    return -1 if url.nil?

    size = -1
    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.head(uri.path)
      size = response.content_length unless response.nil?
    end
    size
  end

  def download
    raise "nil URL" if url.nil?

    # check file size
    rsize = remote_size
    return false if rsize < 0 || rsize > MAX_SIZE

    # download file
    File.open(file_name, 'wb') do |f|
      logger.info("Song ##{id} - downloading from #{url}")
      f.write(URI.parse(url).read)
    end
  end
  
  def import_metadata
    Mp3Info.open(file_name) do |mp3|
      self.title = clean(mp3.tag.title || url.split('/').last.gsub(/\.mp3/, ''))
      self.artist = clean(mp3.tag.artist || "Unknown")
    end if has_file?
  end

  private
  
  def clean(input)
    input.gsub(/[^A-Za-z0-9_  \(\)&-\.]/, '').gsub(/  /, ' ').strip
  end
  
  def save_tags
     Mp3Info.open(file_name) do |mp3|
       mp3.tag.title = title unless title.nil?
       mp3.tag.artist = artist unless artist.nil?
     end if has_file?
   end
end
