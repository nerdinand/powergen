#require "grabber/*.rb"
#require 'scruffy'
require 'gruff'

include Grabber

class GrabbingSource

  @keyword
  @twitter_used
  @@chart_filename = "chart_gruff_a"

  def initialize(keyword)
    @keyword=keyword
    topic_finder = TopicFinder.new
    @wikipedia_grabber = topic_finder.grabber(keyword)
    @google_image_grabber = GoogleImageGrabber.new(keyword)
    @flick_grabber = FlickrGrabber.new(keyword)
    @google_search_grabber = GoogleSearchGrabber.new(keyword)
    @twitter_grabber = TwitterGrabber.new(keyword)
    @iheartquotes_grabber = IheartquotesGrabber.new

    @twitter_used = false
    @next_catchword=:wikipedia
  end

  def topics
    wikipedia_grabber.topics
  end

  def link
    link = google_search_grabber.link

    unless link
      link = wikipedia_grabber.link
    end

    link
  end

  def catchword
      word=wikipedia_grabber.catchword
    unless word
      word=google_search_grabber.catchword
    end

    if word
      word
    else
      "no more catchwords"
    end
  end

  def sentence
    sentence=wikipedia_grabber.sentence

    unless sentence
      sentence=google_search_grabber.sentence
      
    end

    sentence
  end

  def picture
    picture=flickr_grabber.picture

    unless picture
      picture = google_image_grabber.picture
    end

    picture
  end

  def keyword
    wikipedia_grabber.keyword
  end

  def number
    wikipedia_grabber.number
  end

  def quote
    if @twitter_used
      chosen_quote = iheartquotes_grabber.quote
    else
      chosen_quote = twitter_grabber.quote
      @twitter_used = true
    end

    if chosen_quote
      chosen_quote
    else
      "I don't know what to say...\n\n        Chuck Norris"
    end
  end

  def chart_big
    #options = ["cht=p&chs=300x230"]#, "cht=p3&chs=700x375", "cht=bhs&chs=600x200", "cht=bvg&chs=200x475"]
    #options = ["cht=p&chs=500x300"]
    #chart(options.pick)

    g = Gruff::Pie.new("1000x1000")
    #g.title = "Early years"
    [2,3,4,5].pick.times do
      begin #repeat while number_now==0
        number_now = number.abs
      end while number_now==0
      
      if number_now > 100.0
        number_now = (1.0/number_now)*100.0
      end
      while number_now < 1.0
          number_now = number_now*10.0
      end

      g.data catchword, number_now
    end
    file_name = "pictures/"+@@chart_filename.succ!+".pdf"
    #puts "==== file_name: #{file_name}"
    g.write(file_name)
    file_name
  end

  def chart_small
    #options = ["cht=p&chdlp=bv&chs=300x237"]#, "cht=p3&chdlp=bv&chs=600x275", "cht=bhs&chdlp=bv&chs=300x200", "cht=bvg&chdlp=bv&chs=250x400"]
    #options = ["cht=p&chdlp=bv&chs=200x350"]
    #chart(options.pick)

    g = Gruff::Pie.new("800x800")
    g.legend_font_size = 30
    g.marker_font_size = 30
    #g.title_font_size = 14
    #g.title = "Early years"
    [2,3,4,5].pick.times do
      begin #repeat while number_now==0
        number_now = number.abs
      end while number_now==0

      if number_now > 100.0
        number_now = (1.0/number_now)*100.0
      end
      while number_now < 1.0
          number_now = number_now*10.0
      end

      g.data catchword, number_now
    end
    file_name = "pictures/"+@@chart_filename.succ!+".pdf"
    #puts "==== file_name: #{file_name}"
    g.write(file_name)
    file_name
  end

  private
  def google_image_grabber
    @google_image_grabber
  end

  def flickr_grabber
    @flick_grabber
  end

  def wikipedia_grabber
    @wikipedia_grabber
  end

  def google_search_grabber
    @google_search_grabber
  end

  def twitter_grabber
    @twitter_grabber
  end

  def iheartquotes_grabber
    @iheartquotes_grabber
  end

  def chart(chart_props)
    numbers = Array.new
    parts = Array.new
    [2,3,4,5].pick.times do
      numbers.push number.to_s
      parts.push catchword
    end

    numbers_url = numbers.join(",")
    parts_url = parts.join("|")
    how_many = numbers.length
    color_url = ["FF0000", "00FF00", "0000FF", "FF00FF", "000000"].first(how_many).join("|")
    #red, green, blue, black, white

    #http://chart.apis.google.com/chart?cht=p&chdlp=bv&chs=240x135&chd=t:10,10,10,10,60&chco=FF0000|00FF00|0000FF|FF00FF|000000&chdl=Foo|Bar|Baz|Moep|Blah

    url = "http://chart.apis.google.com/chart?"+
      "#{chart_props}&"+
      "chd=t:#{numbers_url}&"+
      "chco=#{color_url}&"+
      "chdl=#{parts_url}&chts=000000,20"

    url = URI.escape(url)
    #puts "chart: #{url}"
    picture_uri =URI.parse(url)
    puts "picture_uri: #{picture_uri}"
    GrabberHelper.download_google_chart(picture_uri)
  end
end
