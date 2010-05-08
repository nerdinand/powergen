# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'grabber/wikipedia.rb'

class TopicFinder
  
  def grabber(keyword)
    wikipedia_grabber=Grabber::WikipediaGrabber.new(keyword)
    if wikipedia_grabber.good_keyword?
      wikipedia_grabber
    else
      find_new_keyword(wikipedia_grabber)
    end   
  end

  def find_new_keyword(wikipedia_grabber)
    new_keyword = wikipedia_grabber.catchword
    puts "====== TopicFinder: The new keyword is: #{new_keyword}"
    wikipedia_grabber = Grabber::WikipediaGrabber.new(new_keyword)
    if wikipedia_grabber.good_keyword?
      wikipedia_grabber
    else
      find_new_keyword(wikipedia_grabber)
    end
  end
end
