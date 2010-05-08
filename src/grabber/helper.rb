require "grabber/abstract.rb"

module Grabber
  class GrabberHelper

    @@dummy_chart_name="chart_a"

    def GrabberHelper.download_google_chart(uri)
      file_name=Grabber::AbstractGrabber.picture_folder_name + @@dummy_chart_name.succ! + ".png"
      #puts "GrabberHelper.download_google_chart, file_name: #{file_name}"

      file=File.open(file_name, "w"){ |f|
        f.write(Net::HTTP.get(uri))
      }

      file_name
    end

    def GrabberHelper.download_file(uri)
      file_name= Grabber::AbstractGrabber.picture_folder_name + uri.path.split("/").last

      #puts "GrabberHelper.download_file, file: #{file_name}"

      file=File.open(file_name, "w"){ |f|
        f.write(Net::HTTP.get(uri))
      }

      file_name
    end
  end
end
