#!/usr/bin/ruby

$: << File.expand_path(File.dirname(__FILE__) + "/grabber")
require 'rubygems'
require 'latex_beamer.rb'
#Dir[File.dirname(__FILE__) + '/grabber/*_grabber.rb'].each {|file| require file }
require 'grabber/wikipedia.rb'
require 'grabber/flickr.rb'
require 'grabber/google_image.rb'
require 'grabber/google_search.rb'
require 'grabber/twitter.rb'
require 'grabber/iheartquotes_grabber.rb'
require 'topic_finder.rb'
require 'slide_set_maker.rb'

class Generator

  def initialize(word)
    @word =word
  end
  
  def go!
    slide_set_maker = SlideSetMaker.new(@word)
    slide_set_maker.generate
  end

end

unless ARGV.empty?
  word=ARGV[0]
else
  puts "Usage: PowerPointGenerator <keyword>"
  exit
end

g=Generator.new(word)
g.go!


