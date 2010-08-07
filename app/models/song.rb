class Song < ActiveRecord::Base
  
  # STATES
  # found => { downloaded, error, hidden }
  # downloaded => { active, hidden }
  # active => { hidden }
  # error => { found }
  # hidden => { found, downloaded }

  MAX_SIZE = 20971520
  RECENT_DEFAULT = 30

  belongs_to :site
  
  has_many :playlist_items, :dependent => :destroy
  has_many :playlists, :through => :playlist_items

  validates_uniqueness_of :url

  after_save :save_tags
  before_destroy :delete_file!
  
  scope :active, where(:active => true)

  def self.recent(limit = RECENT_DEFAULT)
    limit(limit).order("created_at DESC")
  end

  def css_selector
    "#song_#{id}"
  end

  def to_s
    "#{artist} - #{title}"
  end

  def to_param
    "#{id}-#{slug_text(artist)}-#{slug_text(title)}"
  end
  
  def download_filename
    "#{self}.mp3"
  end

  def filename
    site.data_dir.join "#{id}.mp3"
  end
  
  def file_size
    File.size? filename
  end

  def has_file?
    !file_size.nil?
  end

  def delete_file!
    File.delete(filename) if has_file?
  end

  def uri
    @uri ||= URI.parse(url)
  end

  def remote_size
    return -1 if url.nil?

    Net::HTTP.start(uri.host, uri.port) do |http|
      http.head(uri.path).content_length
    end
  end

  def download(force = false)
    raise "nil URL" if url.nil?
    raise "file exists" if has_file? && !force
    raise "file too big" unless (0..MAX_SIZE).include? remote_size

    data = uri.read
    File.open(filename, 'wb'){ |f| f.write data }
  end
  
  def import_metadata
    Mp3Info.open(filename) do |mp3|
      self.title = clean_text(mp3.tag.title || url.split('/').last.gsub(/\.mp3/, ''))
      self.artist = clean_text(mp3.tag.artist || "Unknown")
      self.album = clean_text(mp3.tag.album || "Unknown")
    end if has_file?
  end

  private
  
  def clean_text(input)
    input.gsub(/[^A-Za-z0-9_  \(\)&-\.]/, '').gsub(/  /, ' ').strip
  end

  def slug_text(input)
    ret = input.strip
    ret.gsub! /['`.]/, ''
    ret.gsub! /\s*@\s*/, ' at '
    ret.gsub! /\s*&\s*/, ' and '
    ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'
    ret.gsub! /_+/, '_'
    ret.gsub! /\A[_\.]+|[_\.]+\z/, ''
    ret
  end

  def save_tags
    Mp3Info.open(filename) do |mp3|
      %w{title artist album}.each do |attr|
        mp3.tag[attr] = self[attr] if attribute_present? attr
      end
    end if has_file?
  end

end
