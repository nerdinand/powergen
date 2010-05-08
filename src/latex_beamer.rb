module LatexEscapable
  def latex_escape!
    self.latex_escape_hash!({"ä"=>"\\\"a", 'ö'=>"\\\"o", 'ü'=>"\\\"u", "“"=>'"', "_"=>"\\\\_", "#"=>"\\#", "$"=>"\\$", "%"=>"\\%", "&"=>'\\\\&', "~"=>"\\~", "^"=>"\\^", "{"=>"\\{", "}"=>"\\}" })
  end
  
  def make_nice
    str=self.latex_escape!

    #str=self.delete "^a-z", "^A-Z", "^., \n-!:/"
    str
  end

  def latex_escape_hash!(pattern_replacement_hash)
    pattern_replacement_hash.each_pair {|pattern, replacement|
      #puts "Pattern: #{pattern} replacement: #{replacement}"
      self.gsub!(pattern, replacement)
    }

    self
  end
end

class String
  include LatexEscapable
end

module LatexBeamer

  class BeamerDocument

    def initialize(atitle, anauthor)
      @title=atitle.make_nice
      @author=anauthor.make_nice
      @content=""
    end

    def to_s
      header+content+footer
    end

    def graphics(graphics)
      @content << ("\\begin{center}\n\\includegraphics[keepaspectratio,width=\\textwidth, height=.8\\textheight]{#{graphics}}\\end{center}\n")
    end

    def graphics_chart(graphics)
      @content << ("\\begin{center}\n\\includegraphics[keepaspectratio,width=\\textwidth, height=.8\\textheight]{#{graphics}}\\end{center}\n")
    end

    def huge_content_do
      @content << "\\Huge{"
      yield
      @content << "}\n"
    end

    def raw_content(content)
      @content << (content.to_s.make_nice)
    end

    def new_frame!(name)
      @content << "\\frame{#{name.make_nice}}\n"
    end
    
    def new_section!(name)
      @content << "\\section{#{name.make_nice}}\n"
    end

    def table(data)
      colcount =data[0].size
      @content << "\\begin{tabular}{"+"|"+"l|"*colcount+"}\n"
      @content << "\\hline\n"

      data.each{ |row|
        row.each { |cell|
          @content << cell.to_s.latex_escape! << " &"
        }
        @content.chop!
        @content << "\\\\ \\hline\n"
      }
      
      @content << "\\end{tabular} \n"
    end
    
    def item(text)
      @content<<escaped_item(text.latex_escape!)<<"\n"
    end

    def items(item_array)
      item_array.each { |item|
        item(item)
      }
    end

    def itemize(item_array)
      items=""
      item_array.each { |item|
        items<<escaped_item(item.latex_escape!)<<"\n"
      }

      items
    end

    def itemize_without_escaping(item_array)
      items=""
      item_array.each { |item|
        items<<escaped_item(item)<<"\n"
      }

      items
    end

    def frame_with_title_do(title)
      @content << "--- " << title.make_nice << "\n"
      yield
      @content << "---" << "\n"
    end

    def graphics_columns(picture, picture2)
      escaped_columns(latex_picture(picture), latex_picture(picture2))
    end

    def graphics_unscaled_columns(picture, picture2)
      escaped_columns(latex_unscaled_picture(picture), latex_unscaled_picture(picture2))
    end

    def graphics_text_columns(picture, text)
      escaped_columns(latex_picture(picture), text.latex_escape!)
    end

    def graphics_unscaled_text_columns(picture, text)
      escaped_columns(latex_unscaled_picture(picture), text.latex_escape!)
    end

    def text_graphics_columns(text, picture)
      escaped_columns(text.latex_escape!, latex_picture(picture))
    end

    def text_graphics_unscaled_columns(text, picture)
      escaped_columns(text.latex_escape!, latex_unscaled_picture(picture))
    end

    def text_columns(left, right)
      escaped_columns(left.latex_escape!, right.latex_escape!)
    end

    def latex_picture(picture_name)
      "\\includegraphics[keepaspectratio,width=1.0\\textwidth, height=1.0\\textheight]{#{picture_name}}"
    end

    def latex_unscaled_picture(picture_name)
      "\\includegraphics{#{picture_name}}"
    end

    private

    def escaped_item(item)
      " * "<< item
    end

    def escaped_columns(left, right)
      left.to_s
      right.to_s
      @content << "\\begin{columns}\n\\column{.55\\textwidth}\n"
      @content << left << "\n"
      @content << "\\column{.45\\textwidth}\n"
      @content << right << "\n"
      @content << "\\end{columns}\n"
    end

    def content
      @content
    end

    def footer
      FOOTER
    end

    def header
      HEADER+title_string+author_string+begin_document
    end

    def begin_document
      "\\begin{document}\n\\frame{\\titlepage}\n"
    end

    def title_string
      "\\title{#{@title}}\n"
    end

    def author_string
      "\\author{#{@author}}\n"
    end
    
    FOOTER="\\end{document}"
    HEADER="\\documentclass{beamer}\n\\usepackage{beamerthemesplit}\n\\usepackage{graphicx}\n
\\usepackage{pgfpages}\n\\pgfpagesuselayout{resize to}[a4paper,border shrink=5mm,landscape]\n\\date{\\today}\n"
  end
end

