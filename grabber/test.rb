#require 'rubygems'
#require 'scruffy'
#
#    graph = Scruffy::Graph.new
#    graph.title = "Favourite Snacks"
#    graph.renderer = Scruffy::Renderers::Pie.new
#
#    graph.add :pie, '', {
#      'Apple' => 20,
#      'Banana' => 100,
#      'Orange' => 70,
#      'Taco' => 30
#    }
#
#    graph.render :to => "scruffy_pie.svg", :size => [300,200]
#    graph.render :to => "scruffy_pie.pdf", :as => 'pdf', :size => [300,200]

require 'rubygems'
require 'gruff'

g = Gruff::Pie.new
  g.title = "Early years"
  g.data 'Richard Stallman', 20
  g.data 'karate', 50
  g.write("pie_keynote.pdf")

