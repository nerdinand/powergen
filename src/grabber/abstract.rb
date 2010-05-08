# To change this template, choose Tools | Templates
# and open the template in the editor.

module Grabber
  class AbstractGrabber

    def AbstractGrabber.picture_folder_name
      "pictures/"
    end

    def features
      raise NotImplementedError
    end

    def picture
      raise NotImplementedError
    end

    def text
      raise NotImplementedError
    end

    def link
      raise NotImplementedError
    end

    def keyword
      raise NotImplementedError
    end

    def number
      raise NotImplementedError
    end

    def quote
      raise NotImplementedError
    end

  end
end
