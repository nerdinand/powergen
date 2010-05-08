require 'fileutils'
require 'slide_maker.rb'
require 'grabbing_source.rb'
require 'rand.rb'

class SlideSetMaker

  @word
  attr_accessor :document
  attr_accessor :grabber
  @slide_maker

  def initialize(word)
    @word = word
  end

  def generate
    puts "Starting to compile slideset."
    unless File.exists?"pictures"
      FileUtils.mkdir "pictures"
    end

    @document =LatexBeamer::BeamerDocument.new(@word, "PowerPointGenerator")
    @slide_maker = SlideMaker.new self
    
    @grabber = GrabbingSource.new @word

    if grabber.topics.length >= 10
      chosen_topics = grabber.topics.first(10)
    else
      chosen_topics = grabber.topics
    end

    chosen_topics.compact! # there should not be any nil elements, but somehow there are (keyword "House")
    puts "=== Chosen topics: #{chosen_topics.inspect}"

    chosen_topics.each {|topic|
      slide_for_topic(topic)
    }

    @document.frame_with_title_do("Links"){
      [2,3,4,5].pick.times {
        @document.item(grabber.link)
      }
    }

    @document.frame_with_title_do("Questions"){
      @document.huge_content_do{
        @document.raw_content("Questions?")
      }
    }

    #puts @document
    puts "Write tex file."
    file_name=@word.split(" ").join
    File.open(file_name+".tex", 'w'){ |f| f.write(@document)}
    #exec "ruby brex.rb #{file_name}.tex"
    puts "Execute brex and pdflatex."
    puts `ruby brex.rb #{file_name}.tex`
    platform = RUBY_PLATFORM
    if platform
      if platform.include? "linux"
        `xdg-open #{file_name}.pdf`
        puts "Open PDf file on a Linux machine"
      elsif platform.include? "darwin"
        `open #{file_name}.pdf`
      end
    end
    FileUtils.rm_rf "pictures"
    #exec "rm *.jpg *.png"
    puts "Finished."
  end

  def slide_for_topic(topic)
    @slide_maker.new_slide(topic)
  end

end
