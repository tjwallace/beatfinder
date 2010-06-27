class Song < ActiveRecord::Base
  MAX_SIZE = 20971520
  RECENT_DEFAULT = 30

  belongs_to :site

  scope :active, where(:active => true)

  validates_uniqueness_of :url, :file_name

  after_save :save_tags
  before_destroy :delete_file

  def self.recent(limit = RECENT_DEFAULT)
    limit(limit).order("created_at DESC")
  end

  def to_s
    "#{artist} - #{title}"
  end

  def has_file?
    !file_name.nil? && !file_size.nil?
  end

  def delete_file
    File.delete(file_name) unless file_name.nil?
  end

  def save_tags
    if has_file?
      Mp3Info.open(file_name) do |mp3|
        mp3.tag.title = title unless title.nil?
        mp3.tag.artist = artist unless artist.nil?
      end

      smart_rename
    end
  end

  def file_size
    File.size?(file_name) unless file_name.nil?
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

    # setup download file_name
    self.file_name = File.join(site.data_dir, clean(url.split('/').last))
    save!

    # check file size
    rsize = remote_size
    return false if rsize < 0 || rsize > MAX_SIZE

    # download file
    File.open(file_name, 'wb') do |f|
      f.write(URI.parse(url).read)
    end

    # update artist and title info
    Mp3Info.open(file_name) do |mp3|
      self.title = clean(mp3.tag.title || url.split('/').last.gsub(/\.mp3/, ''))
      self.artist = clean(mp3.tag.artist || "Unknown")
    end

    # rename file
    smart_rename

    self.active = true;
    save!
  end

  private
  
  def clean(input)
    input.gsub(/[^A-Za-z0-9_  \(\)&-\.]/, '').gsub(/  /, ' ').strip
  end

  def clean_for_fn(input)
    clean(input).gsub(/ /, '_').downcase
  end

  def smart_rename
    return if artist.nil? || title.nil?
    old_file_name = file_name
    self.file_name = File.join(site.data_dir, clean_for_fn("#{self.to_s}.mp3"))
    File.rename(old_file_name, file_name)
  end
end
