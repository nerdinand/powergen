#!/usr/bin/env ruby

# == Synopsis
#   Beamer-Ruby-Latex, b-rex in short, is a program for pre-parsing
#   latex beamer presentations & papers, and building them with
#   pdflatex and bibtex.
#
# == Usage
#   To turn tex file into pdf
#     ./b-rex beamer.tex
#
#   Other examples:
#     b-rex -a beamer.tex
#     b-rex -e --verbose beamer.tex
#
# In Presentations
#
# Instead of:
#
#   \begin{frame}
#     \frametitle{My Very Title}
#     bigskip
#
#     \begin{itemize}
#       \item this point people
#       \item do not forget
#     \end{itemize}
#   \end{frame}
#
# You can write:
#
#   --- My Very Title
#
#    * this point people
#    * do not forget
#
#   ---
#
# It is capable of falling back to normal latex where needed (for the
# title-page you still use normal latex) and also has support for
# slides with an image, tables of contents, an intro-frame and
# higlighted words (by enclosing them in '~''s, ~like this~)
#
# For more info and example presentations see:
# http://en.logilogi.org/Wybo_Wiersma/User/Beamer_Ruby_Latex
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -V, --verbose       Verbose output
#   -a, --assemble      Follows all includes and makes it a single file
#   -e, --expand        Assembles and expands to normal tex (does not
#                       turn it into a pdf yet)
#
# == Requirements
#   Ruby (inc rdoc, not included in Debian & Ubuntu, needs ruby and rdoc
#   packages there), Latex beamer, and a working TeX Live (the texlive
#   and latex-beamer packages are all you need on Ubuntu)
#
# == Copyright
#   Copyright (c) 2007 The LogiLogi Foundation. Licensed under the
#   Affero GPL: http://www.fsf.org/licensing/licenses/agpl-3.0.html

require 'optparse'
require 'rdoc/usage'
require 'ostruct'
require 'date'

class BRex
  VERSION = '0.5.3'

  ASSEMBLED_SUFFIX = '.assembled'
  EXPANDED_SUFFIX = '.expanded'
  BASE_PATH = '.'

  attr_reader :options

  def initialize(arguments)
    @arguments = arguments

    # Set defaults
    @options = OpenStruct.new
    @options.verbose = false
    @options.process = false
    @options.assemble = false
    @options.expand = false
  end

  # Parse options, check arguments, then process the command
  def run
    if parsed_options? && arguments_valid?
      puts "Start at #{DateTime.now}\\n\\n" if @options.verbose

      output_options if @options.verbose
      preprocess_options
      run_app

      puts "\\nFinished at #{DateTime.now}" if @options.verbose
    else
      output_usage
    end
  end

  protected

  def parsed_options?
    # Specify options
    opts = OptionParser.new
    opts.on('-v', '--version')    { output_version ; exit 0 }
    opts.on('-h', '--help')       { output_help }
    opts.on('-V', '--verbose')    { @options.verbose = true }
    opts.on('-a', '--assemble')   { @options.assemble = true }
    opts.on('-e', '--expand')     { @options.expand = true }

    opts.parse!(@arguments) rescue return false
    @options.filename = @arguments[0]
    true
  end

  def output_options
    puts "Options:\\n"

    @options.marshal_dump.each do |name, val|
      puts "  #{name} = #{val}"
    end
  end

  # True if required arguments were provided
  def arguments_valid?
    if @options.assemble and @options.expand
      puts "process, assemble and expand are mutually exclusive options"
      return false
    end
    return true
  end

  def preprocess_options
    if @options.expand
      @options.assemble = true
    elsif !@options.assemble
      @options.assemble = @options.expand = @options.make = true
    end
  end

  def output_help
    output_version
    RDoc::usage() #exits app
  end

  def output_usage
    RDoc::usage('usage') # gets usage from comments above
  end

  def output_version
    puts "#{File.basename(__FILE__)} version #{VERSION}"
  end

  def run_app
    if @options.assemble
      assemble(@options.filename)
    end
    if @options.expand
      expand(@options.filename)
    end
    if @options.make
      make(@options.filename)
    end
  end

  def assemble(filename)
    check_filename_argument(filename, 'latex-file')
    contents = assemble_text_file(BASE_PATH, filename)
    File.open(BASE_PATH + '/' + filename + ASSEMBLED_SUFFIX, 'w') do |target|
      target.write(contents)
    end
  end

  def expand(filename)
    check_filename_argument(filename, 'assembled latex-file')
    contents = File.open(File.expand_path(filename + ASSEMBLED_SUFFIX, BASE_PATH)).read
    contents = expand_item_lists(contents)
    contents = expand_frames(contents)
    contents = expand_styles(contents)
    File.open(BASE_PATH + '/' + filename + EXPANDED_SUFFIX + '.tex', 'w') do |target|
      target.write(contents)
    end
    system "cd #{BASE_PATH}; rm #{filename + ASSEMBLED_SUFFIX}"
  end

  def make(filename)
    check_filename_argument(filename, 'latex-file')
    to_pdf_file = filename.gsub(/\.tex/,'.pdf')
    processed_head = filename + EXPANDED_SUFFIX
    ["pdflatex #{processed_head}",
     "bibtex #{processed_head}",
     "pdflatex #{processed_head}",
     "pdflatex #{processed_head}",
     "mv #{processed_head}.pdf #{to_pdf_file}",
     "rm #{processed_head}.*"
     ].each do |action|
      system "cd #{BASE_PATH}; #{action}"
    end
  end

  # Sub-sub-functions

  def assemble_text_file(base_path,filename)
    if !File.directory?(base_path)
      base_path = File.dirname(base_path)
    end
    contents = File.open(File.expand_path(filename, base_path)).read
    contents.gsub!(/(^|\n)[ \t]*\\input\{.*?\}/) do |inc|
      inc =~ /input\{(.*?)\}/
      match = $~
      "\n" + assemble_text_file(base_path + '/' + filename, match[1])
    end
    return contents
  end


  NESTING_TYPES = {'*' => 'itemize', '#' => 'enumerate'}

  def expand_item_lists(contents)
    lines = contents.split("\n")
    # Item-lists
    whitespaces_in_line = 0
    whitespaces_in_last_line = 0
    item_nestings = []
    nr = 0
    lines.collect! do |line|
      line_begin = ''
      if line =~ /^(\s*)(\*|#)(.+)/
        match = $~
        line = match[3]
        whitespaces_in_line = match[1].size
        if whitespaces_in_line > whitespaces_in_last_line
          nesting = NESTING_TYPES[match[2]]
          item_nestings.push(nesting)
          line_begin += ' ' * whitespaces_in_line + '\begin{' + nesting + '}' + "\n"
        elsif whitespaces_in_line < whitespaces_in_last_line and
            item_nestings.size > 0
          nesting = item_nestings.pop
          line_begin += ' ' * whitespaces_in_last_line + '\end{' + nesting + '}' + "\n"
        end
        line_begin += ' ' * (whitespaces_in_line + 2) + '\item'
      else
        if item_nestings.size > 0
          item_nestings.each do |nesting|
            line_begin += ' ' * whitespaces_in_last_line + '\end{' + nesting + '}' + "\n"
            whitespaces_in_last_line = step_down_whitespaces(whitespaces_in_last_line)
          end
        elsif whitespaces_in_last_line > 0
          raise 'Problem closing nesting on line ' + nr.to_s + ' of the composed file'
        end
        item_nestings = []
        whitespaces_in_line = 0
      end
      whitespaces_in_last_line = whitespaces_in_line
      nr += 1
      line_begin + line
    end
    return lines.join("\n")
  end

  def expand_frames(contents)
    lines = contents.split("\n")
    # Frames + titles
    open = false
    old_frame_fun_str = ""
    old_frame_arg_str = ""
    lines.collect! do |line|
      if line =~ /^\s*---(\w*)\s*(.*)\s*$/
        match = $~
        frame_fun_str = "frame_" + (!match[1].empty? ? match[1] : "default")
        frame_arg_str = match[2]
        if !frame_arg_str.empty?
          if frame_fun_str == "frame_default"
            # add quotes to the title
            frame_arg_str = '"' + frame_arg_str + '"'
          end
          frame_arg_str += ", "
        end
        if open
          # close it with the previous args
          self.check_frame_function(old_frame_fun_str)
          line = eval old_frame_fun_str + "(" + old_frame_arg_str + ":open => false)"
          open = false
        else
          # open a new one
          self.check_frame_function(frame_fun_str)
          line = eval frame_fun_str + "(" + frame_arg_str + ":open => true)"
          open = true
        end
        if !frame_arg_str.empty?
          # open again when chained
          if !open
            line += "\n\n" +
              (eval frame_fun_str + "(" + frame_arg_str + ":open => true)")
            open = true
          end
        end
        old_frame_fun_str = frame_fun_str
        old_frame_arg_str = frame_arg_str
      else
        if open and !line.empty?
          # extra indentation
          line = '  ' + line
        end
      end
      line
    end
    if open
      raise 'Frames not closed'
    end
    return lines.join("\n")
  end

  def check_frame_function(frame_fun_str)
    if !self.respond_to?(frame_fun_str)
      raise "Frame kind '#{frame_fun_str}' does not exist, leave a space between --- <and the title>"
    end
  end

  def expand_styles(contents)
    lines = contents.split("\n")
    # Yellow words
    lines.collect! do |line|
      line.gsub!(/~(.*?)~/,'\textcolor[rgb]{0.80,0.20,0.20}{\1}')
      line
    end
    return lines.join("\n")
  end

  def frame_default(title, options = {})
    if options[:open]
      '\begin{frame}[fragile]' + "\n" +
      '  \frametitle{' + title + '}' + "\n" +
      '  \bigskip'
    else
      '\end{frame}'
    end
  end

  def frame_intro(options = {})
    if options[:open]
      '\begin{frame}[plain]' + "\n" +
      '\vspace{8mm}' + "\n" +
      '  \begin{columns}' + "\n" +
      '    \column{15mm}' + "\n" +
      '    \column{8cm}'
    else
      '  \end{columns}' + "\n" +
      '\end{frame}'
    end
  end

  def frame_contents(title, options = {})
    if options[:open]
      '\begin{frame}[fragile]' + "\n" +
      '  \frametitle{' + title + '}'
    else
      '  \tableofcontents[currentsection, hideothersubsections]' + "\n" +
      '\end{frame}'
    end
  end

  def frame_image(image, title, options = {})
    if options[:open]
      '\begin{frame}' + "\n" +
      '  \frametitle{' + title + '}'
    else
      if options[:max].kind_of?(Hash)
        key = options[:max].keys.first
        limit = key.to_s + '=' + options[:max][key]
      elsif options[:max] == :width
        limit = "width=10cm"
      else
        limit = "height=7.5cm"
      end
      '  \begin{figure}' + "\n" +
      '    \centering' + "\n" +
      '    \includegraphics[' + limit + ']{' + image + '}' + "\n" +
      '  \end{figure}' + "\n" +
      '\end{frame}'
    end
  end

  def step_down_whitespaces(whitespaces)
    whitespaces -= 2 if whitespaces >= 2
    return whitespaces
  end

  def check_filename_argument(filename, file_text)
    if filename.nil?
      puts "Needs filename-argument. The name of the #{file_text}\n"
      output_usage
      exit
    end
  end
end

# Create and run the application
app = BRex.new(ARGV)
app.run
