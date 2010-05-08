
require 'abstract.rb'
require 'net/http'
require 'json'
require 'cgi'

module Grabber

  class GoogleSearchGrabber < AbstractGrabber

    #member vars
    @keyword # stored keyword for this grabber
    @links

    def initialize(keyword)
      @keyword = keyword
      # escape white spaces, for instance ==> %20
      esc_keyword = CGI.escape(keyword)
      uri = URI.parse("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{esc_keyword}")
      doc = Net::HTTP.get(uri)

      json = JSON.parse(doc)
      #puts json["responseData"]["results"][0]["url"]
      
      @links = Array.new
      # collect urls in json to @links array
      json["responseData"]["results"].each do |json_sub|
        @links.push json_sub["url"]
      end

      links =@links
      begin
        uri = URI.parse(links.pop)
      end while uri.host.eql? "en.wikipedia.org"
      puts "Google search url: #{uri}"
      doc = Net::HTTP.get(uri)

      visible_text =CGI.unescapeHTML(doc.to_s).gsub(/<\/?[^>]*>/, "")

      @catchwords=visible_text.split(/\s/).uniq.delete_if{|word| word.empty?}.delete_if{|word| /[^a-zA-Z]+/===word}.sort{|a,b| a.size <=> b.size}
      
      @sentences =visible_text.scan(/[\.\?\!\n]([A-Z][^|{\}\*\=\n]*[\.\?\!])/).flatten.delete_if{|sentence| sentence.length<10}
      
    end

    def GoogleSearchGrabber.features
      return [:link, :catchword, :sentence]
    end

    def sentence
      @sentences.pop
    end

    def link
      @links.pop
    end

    def catchword
      @catchwords.pop
    end
  end
    
end
