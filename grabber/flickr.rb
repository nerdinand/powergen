
require 'net/http'
require 'rexml/document'
require 'ostruct'
require 'abstract.rb'
require 'cgi'
require 'helper.rb'

module Grabber
  class FlickrGrabber < AbstractGrabber

    def initialize(keyword)
      @keyword = CGI.escape(keyword)
    end

    def FlickrGrabber.features
      return [:picture]
    end

    def picture
      unless @flickr_pictures
        @flickr_pictures= Flickr.search(@keyword)
      end

      picture =@flickr_pictures.pop
      if picture
        picture_uri =URI.parse(picture.sizes[3])
        file_name=GrabberHelper.download_file(picture_uri)
      end
      
      file_name
    end
    
  ### this is partly taken from http://snippets.dzone.com/posts/show/3493

  class Flickr < OpenStruct
    include REXML

    @@api_key ="4be6a7bac97a3e8cad9f39f975e56909"

    def Flickr.search(text)
      doc = Document.new(
              Net::HTTP.get(
                URI.parse("http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=#{@@api_key}&extras=license,owner_name,original_format&license=4,5&per_page=50&sort=interestingness-desc&text=" + text)))
       throw "flickr error" unless doc.root.attributes['stat'] == "ok"
       doc.root.elements['photos'].get_elements('//photo').collect {|photo| photo << Flickr.new(photo) }
    end

    def initialize(e)
      super(e.attributes)
      self.new_ostruct_member("photo_id")
      self.photo_id = e.attributes['id']
    end

    def to_url(image_type="s")
      "http://farm#{farm}.static.flickr.com/#{server}/#{photo_id}_#{secret}_#{image_type}.jpg"
    end

    def sizes
    return_sizes=[]
      doc = Document.new(
              Net::HTTP.get(
                URI.parse("http://api.flickr.com/services/rest/?method=flickr.photos.getSizes&api_key=#{@@api_key}&photo_id=#{photo_id}")))
      doc.root.elements['sizes'].get_elements('//size').collect{ |size| return_sizes << size.attributes["source"] }
    return_sizes
    end
  end

  end
end
