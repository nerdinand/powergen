# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'abstract.rb'

module Grabber
  
  class IheartquotesGrabber < AbstractGrabber
    
    def initialize
    end

    def quote
      uri = URI.parse("http://iheartquotes.com/api/v1/random?format=text&max_lines=4")
      doc = Net::HTTP.get(uri)
      doc.to_s
    end
    
  end
end
