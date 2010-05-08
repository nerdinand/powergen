# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'abstract.rb'
require 'net/http'
require 'json'
require 'cgi'
require 'date'

module Grabber
  class TwitterGrabber < AbstractGrabber

    @quotes # twitter quotes

    def TwitterGrabber.features
      return [:quote]
    end

    def initialize(keyword)
      @keyword = CGI.escape(keyword)

      uri = URI.parse("http://search.twitter.com/search.json?q=#{@keyword}")
      doc = Net::HTTP.get(uri)

      json = JSON.parse(doc)

      @quotes = Array.new
      # collect urls in json to @quotes array
      json["results"].each do |json_sub|
        quote_text =CGI.unescapeHTML(json_sub["text"]).delete("#")
        #@quotes.push Quote.new(quote_text, json_sub["from_user"], Date._parse(json_sub["created_at"]))
        @quotes.push quote_text
      end
      @quotes.reverse!
    end

    def quote
      @quotes.pop
    end

    
  end

  class Quote
    attr_accessor :text, :author, :time

    def initialize(text, author, time)
      @text=text
      @author=author
      @time=time
    end
  end
  
end
