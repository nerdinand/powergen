require "rand.rb"


class SlideMaker


  @slide_set_maker

  def initialize(parent)
    @slide_set_maker = parent
    @slide_proportion_type= {40=>:add_bullets, 30=>:add_sentence, 15=>:add_picture, 5=>:add_chart, 5=>:add_quote, 5=>:add_table}
  end

  def new_slide(topic)
    puts "===== New frame with title: #{topic}"
    [1,2,3].pick.times do
      document.frame_with_title_do(topic){
          #eval(self.methods.select{|method| method=~/add.*/}.pick)
          self.send(pick_by_proportion(@slide_proportion_type))
      }
    end
  end

  ### SENTENCE
  
  def add_sentence
    self.send([:add_sentence_only, :add_sentence_picture, :add_sentence_chart].pick)
  end

  def add_sentence_only
    puts "===== Adding sentence only"
    document.item(grabber.sentence)
  end
  
  def add_sentence_picture
    puts "===== Adding sentence and picture"
    document.text_graphics_columns(grabber.sentence, grabber.picture)
  end

  def add_sentence_chart
    puts "===== Adding sentence and chart"
    document.text_graphics_columns(grabber.sentence, grabber.chart_small)
  end

  ### BULLETS

  def add_bullets
    #add_chart_only # just to test charts
    self.send([:add_bullets_only, :add_bullets_picture, :add_bullets_chart, :add_bullets_bullets].pick)
  end

  def add_bullets_only
    puts "===== Adding bullets only"

    bullets=bullet_list

    document.items(bullets)
  end

  def add_bullets_picture
    puts "===== Adding bullets and picture"

    bullets=bullet_list

    document.text_graphics_columns(document.itemize_without_escaping(bullets), grabber.picture)
  end

  def add_bullets_chart
    puts "===== Adding bullets and chart"

    bullets=bullet_list

    document.text_graphics_columns(document.itemize_without_escaping(bullets), grabber.chart_small)
  end

  def add_bullets_bullets
    puts "===== Adding bullets and bullets"

    bullets =bullet_list
    bullets2 =bullet_list

    document.text_columns(document.itemize_without_escaping(bullets), document.itemize_without_escaping(bullets2))

  end

  ### PICTURE

  def add_picture
    self.send([:add_picture_only, :add_picture_picture, :add_picture_chart, :add_picture_quote].pick)
  end

  def add_picture_only
    puts "===== Adding picture only"

    picture=grabber.picture
    document.graphics(picture)
  end

  def add_picture_picture
    puts "===== Adding picture and picture"

    picture=grabber.picture
    picture2=grabber.picture
    
    document.graphics_columns(picture, picture2)
  end

  def add_picture_chart
    puts "===== Adding picture and chart"

    document.graphics_columns(grabber.chart_small, grabber.picture)
  end

  def add_picture_quote
    puts "===== Adding picture and quote"

    document.text_graphics_columns(grabber.quote, grabber.picture)
  end

  ### CHART

  def add_chart
    self.send([:add_chart_only, :add_chart_chart, :add_chart_quote, :add_chart_table].pick)
  end

  def add_chart_only
    puts "===== Adding chart only"
    picture=grabber.chart_big
    document.graphics_chart(picture)
  end

  def add_chart_chart
    puts "===== Adding chart and chart"

    picture=grabber.chart_small
    picture2=grabber.chart_small

    document.graphics_columns(picture, picture2)
  end

  def add_chart_quote
    puts "===== Adding chart and quote"

    document.graphics_text_columns(grabber.chart_small, grabber.quote)
  end

  def add_chart_table
    puts "===== Adding chart and table"

    document.graphics_text_columns(grabber.chart_small, document.table(table_data))
  end

  ### QUOTE

  def add_quote
    add_quote_only
  end

  def add_quote_only
    puts "===== Adding quote only"
    document.item(grabber.quote)
  end

  ### TABLE

  def add_table
    add_table_only
  end

  def add_table_only
    puts "===== Adding table only"

    document.table(table_data)
  end



  
  def pick_by_proportion(proportion_hash)
    values_array=[]

    proportion_hash.each_pair{|proportion, value|
      proportion.times{
        values_array.push value
      }
    }

    values_array.pick
  end


  def document
    @slide_set_maker.document
  end

  def grabber
    @slide_set_maker.grabber
  end


  private
  
  def bullet_list
    bullets = Array.new
    bullet_number = [3,4,5,6,7,8].pick

    bullet_number.times do
      new_item = grabber.catchword
      bullets.push new_item if new_item
    end
    
    bullets
  end

  def table_data
    years=(1900..2020).to_a
    years.shuffle!
    
    data=[]
    header=[" "]
    (1..4).pick.times{
      header << grabber.catchword
    }
    data << header

    unit =["m", "cm", "l", "km", "byte", ""].pick

    num_cols =header.size

    (1..8).pick.times{
      row=[years.pop]
      (num_cols-1).times{
        row << grabber.number.to_s+" "+unit
      }
      data << row
    }

    #puts data.inspect

    data
  end
end
