class Editor
  attr_accessor :width
  attr_accessor :height
  attr_accessor :position
  attr_accessor :buffer
  attr_accessor :line_selected

  def initialize
    @position = 0
    @width = `/usr/bin/env tput cols`.to_i
    @buffer = ''
    @history = File.read(ENV['HOME']+'/.zsh_history').force_encoding("iso-8859-1").split("\n").map {
        |e| e[/: [0-9]+:0;(.*)/, 1]
    }.compact
    @prompt = '$> '
    @line_selected = 0
    @completions = []
  end

  def print_line
    print "\033[K" # erase to end of line
    print @prompt + @buffer
    print "\e[D" * (@buffer.length - @position)
  end

  def add_char(c)
    @buffer.insert(@position, c)
    @position = @position + 1
    print c
  end

  def chop_char
    last_char = @buffer[-1]
    @buffer = @buffer[0..-2]
    self.move_cursor :left
    last_char
  end

  def move_cursor(where)
    {left: -> {
      @position = [@position - 1, 0].max
    }, right: -> {
      @position = [@position + 1, @buffer.length].min
    }, home: -> {
      @position = 0
    }, end: -> {
      @position = @buffer.length
    }}[where].call
  end

  def tab
    return if @line_selected == 0
    @buffer = @completions[@line_selected - 1]
    @position = @buffer.length
    @line_selected = 0
  end

  def enter
    #print "\033[6A"
    print "\e[D" * (@position + @prompt.length)
    print "\033[K"
    print @prompt
    puts @buffer
  end

  def select_line(type)
    @line_selected += {next: 1, previous: -1}[type]
    @line_selected %= (@completions.length + 1)
  end

  def print_completions #(completions)
    #@completions = completions
    @completions.each_with_index do |c, i|
      #print "\033[2B" #down
      #$stdout.flush
      #print "\033[2B" #down
      #$stdout.flush
      puts ''
      if i + 1 == @line_selected
        print "\e[47m"; print "\e[30m" # white bg; black text
      end
      print c
      if i + 1 == @line_selected
        print "\e[0m" # default colors
      end
      # erase to end of line
      print "\033[K"
      #$stdout.flush
    end
    (@completions.length + 1).upto 7 do
      puts "%\033[K"
    end
    #puts ''
    print "\033[7A"
    #print "\033[u" #restore
    #$stdout.flush
  end

  def find_completions
    @completions = @history.map do |h|
      if !h.empty? &&
          (h.start_with?(@buffer) || h.include?(@buffer))
        h[0..(width-1)]
      else
        nil
      end
    end.compact.uniq[0, 6]
  end
end

def read_char
  begin
    # save previous state of stty
    old_state = `stty -g`
    # disable echoing and enable raw (not having to press enter)
    system "stty raw -echo"
    c = STDIN.getc.chr
    # gather next two characters of special keys
    if (c=="\e")
      extra_thread = Thread.new {
        c = c + STDIN.getc.chr
        c = c + STDIN.getc.chr
      }
      # wait just long enough for special keys to get swallowed
      extra_thread.join(0.00001)
      # kill thread so not-so-long special keys don't wait on getc
      extra_thread.kill
    end
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
    puts ex.backtrace
  ensure
    # restore previous state of stty
    system "stty #{old_state}"
  end
  return c
end

# takes a single character command
def show_single_key
  c = read_char
  case c
    when " "
      puts "SPACE"
    when "\t"
      puts "TAB"
    when "\r"
      puts "RETURN"
    when "\n"
      puts "LINE FEED"
    when "\e"
      puts "ESCAPE"
    when "\e[A"
      puts "UP ARROW"
    when "\e[B"
      puts "DOWN ARROW"
    when "\e[C"
      puts "RIGHT ARROW"
    when "\e[D"
      puts "LEFT ARROW"
    when "\177"
      puts "BACKSPACE"
    when "\004"
      puts "DELETE"
    when /^.$/
      puts "SINGLE CHAR HIT: #{c.inspect}"
    else
      puts "SOMETHING ELSE: #{c.inspect}"
  end
end

#show_single_key while(true)

def check_break_commands(input)
  if input == "\u0003"
    puts '^C'
    exit
  end
  if input == "\u0003"
    puts '^D'
    exit
  end
  #if input == "\e"
  #  puts 'ESC'
  #  exit
  #end
end

def control_character?(char)
  char != char.tr("\u0000-\u001f\u007f\u2028", '')
end

def main
  editor = Editor.new

  selected = 0
  1000.times do
    editor.print_line

    #input =  STDIN.getch
    input = read_char
    check_break_commands(input)

    if input == "\177" # backspace
      editor.chop_char
    elsif input == "\e[A" # key up
      editor.select_line :previous
    elsif input == "\e[B" # key down
      editor.select_line :next
    elsif ('a'..'z').include?(input) || ('A'..'Z').include?(input) || !control_character?(input)
      editor.add_char(input)
    elsif input == ' '
      editor.add_char(input)
    elsif input == "\e[D" # left key
      editor.move_cursor :left
    elsif input == "\e[C" # right key
      editor.move_cursor :right
    elsif input == "\x01" # home key
      editor.move_cursor :home
    elsif input == "\x05" # end key
      editor.move_cursor :end
    elsif input == "\t" # tab key
      editor.tab
    elsif input == "\r" # enter key
      editor.enter
      system(editor.buffer)
      exit()

    end

    completions = ['rzer ezrzerz rzerez rezrzer ze' + input.inspect,
                   'rzer ezrzerz rzf sdfsfsderez rezrzer top: ',
                   'rzer ezrez rezrzer ze',
                   'rzerr ze',
                   'rzer ezrzerz rzerez rezrzer ze']
    completions.shuffle!
    editor.find_completions

    editor.print_completions # completions
  end
end

main()