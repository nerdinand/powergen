
require 'abstract.rb'
require 'net/http'
require 'json'
require 'cgi'

module Grabber
  class WikipediaGrabber < AbstractGrabber

    @keyword
    @sections
    @subsections
    @catchwords
    @links
    @numbers
    @sentences

    attr_reader :keyword

    def features
      return [:sentence, :catchword, :link, :number, :topics]
    end

    def initialize(keyword)
      #start_time = Time.now

      @keyword = keyword
      raw = query_wikipedia(keyword)
      #json = JSON.parse(doc)
      #json = json["query"]["pages"]
      #json = json[json.keys.first]["revisions"][0]["*"]
      #old regexp: @sections = json.scan(/^==([A-Z][a-zA-Z|\s]*)/)

#      if raw.include?("#REDIRECT")
#        redirect = raw.scan(/\[\[([a-zA-Z|\s]*)\]\]/).flatten!.first
#        puts "redirect: #{redirect}"
#        raw = query_wikipedia(redirect)
#      end

      @sections = raw.scan(/^==\s?([A-Z][a-zA-Z|\s]*).*==$/)
      
      @subsections = raw.scan(/^===\s?([A-Z][a-zA-Z|\s]*).*===$/)
      @sections = normalize_topics @sections
      @subsections = normalize_topics @subsections
      @catchwords = raw.scan(/\[\[([^:\]|]*)\]\]/)
      @catchwords.flatten!
      @catchwords.uniq!
      @links = raw.scan(/\[(http:[^\s]*)/)
      @numbers = raw.scan(/\d+[\.]?\d+/)
      @sentences = raw.scan(/[\.\?\!\n]([A-Z][^|{\}\*\=]*[\.\?\!])/).flatten.delete_if{|sentence| sentence.length<10}
      if @sentences
        @sentences.collect! do |sentence|
          sentence.delete!("[]'\n")
        end
        @sentences.compact!
        @sentences = split_sentences @sentences
      end
      
      #puts "sections: #{@sections.inspect}"
      #puts "subsections: #{@subsections.inspect}"
      #puts "keywords: #{@keywords.inspect}"
      #puts "links: #{@links.inspect}"
      #puts "numbers: #{@numbers.inspect}"
      #puts "sentences: #{@sentences.inspect}"
      #end_time = Time.now
      #puts end_time-start_time
    end

    def sentence
      if @sentences
        @sentences.pop
      else
        nil
      end
      
    end

    def catchword
      @catchwords.pop
    end

    def link
      @links.pop[0]
    end

    def number
      @numbers.pop.to_f
    end

    def topics
      @sections + @subsections
    end

    def good_keyword?
      if topics.length > 5
        true
      else
        false
      end
    end

    def normalize_topics(topics)
      topics.flatten!
      topics.compact!
      topics.collect! { |item|
        item.strip
      }
      bad_topics = ["See also", "References", "Further reading", "External links"]
      bad_topics.each do |topic|
        topics.delete(topic)
        #puts "topics after deletion of #{topic}: #{topics.inspect}"
      end
      topics.uniq!
      topics
    end

    def split_sentences(sentences)
      new_sentences = Array.new
      sentences.each { |item|
        new_sentences.concat item.split(". ")
      }
      new_sentences
    end

    def query_wikipedia(keyword)
      esc_keyword = CGI.escape(keyword)
      uri = URI.parse("http://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=content&format=txt&redirects&titles=#{esc_keyword}")
      nethttp = Net::HTTP.new(uri.host)
      initheader = {
        'User-Agent' => 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; de; rv:1.9.2.3) Gecko/20100401 Firefox/3.6.3',
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'de-de,de;q=0.8,en-us;q=0.5,en;q=0.3',
        'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'
      }
      response = nethttp.request_get(uri.path, initheader)
      doc = response.body
#      doc = Net::HTTP.get(uri)
#      doc.to_s
      puts doc
      doc
    end

  end
end