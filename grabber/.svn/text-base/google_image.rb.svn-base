require 'abstract.rb'
require 'net/http'
require 'json'
require 'cgi'
require 'helper.rb'

module Grabber
  class GoogleImageGrabber < AbstractGrabber

    def initialize(keyword)
      @keyword = keyword
      # escape white spaces, for instance ==> %20
      esc_keyword = CGI.escape(keyword)
      uri = URI.parse("http://ajax.googleapis.com/ajax/services/search/images?rsz=large&v=1.0&as_filetype=jpg&q=#{esc_keyword}")
      doc = Net::HTTP.get(uri)

      json = JSON.parse(doc)

      @pictures = Array.new
      # collect urls in json to @pictures array
      json["responseData"]["results"].each do |json_sub|
        @pictures.push URI.parse(json_sub["url"]) unless json_sub["url"].include?("%")
      end
      @pictures.reverse!
    end

    def GoogleImageGrabber.features
      return [:picture]
    end

    def picture
      picture=@pictures.pop
      GrabberHelper.download_file(picture) if picture
    end
  end
end
