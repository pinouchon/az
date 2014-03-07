class Editor
  attr_accessor :width
  attr_accessor :height
  attr_accessor :position
  attr_accessor :buffer

  def initialize
    @position = 0
    @width = `/usr/bin/env tput cols`.to_i
    @buffer = ''
    @history = File.read(ENV['HOME']+'/.zsh_history').force_encoding("iso-8859-1").split("\n").map {
        |e| e[/: [0-9]+:0;(.*)/, 1]
    }
  end

  def print_line
    print "\033[K"
    print "$> " + @buffer
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
    {left: lambda {
      @position = [@position - 1, 0].max
    }, right: lambda {
      @position = [@position + 1, @buffer.length].min
    }, home: lambda {
      @position = 0
    }, end: lambda {
      @position = @buffer.length
    }}[where].call
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

def main
  editor = Editor.new

  #text = ''
  selected = 0
  1000.times do
    editor.print_line

    #input =  STDIN.getch
    input = read_char
    check_break_commands(input)

    if input == "\177" # backspace
      #text = text[0..-2]
      editor.chop_char
      #puts text
      #puts text[0..-1]
      #text += "====="
    elsif input == "\e[A" # key up
      selected = selected - 1
    elsif input == "\e[B" # key down
      selected = selected + 1
    elsif ('a'..'z').include?(input) || ('A'..'Z').include?(input)
      #text += input
      #editor.position = editor.position + 1
      editor.add_char(input)
    elsif input == ' '
      #text += input
      editor.add_char(input)
    elsif input == "\e[D" # left key
      editor.move_cursor :left
      #text += input
    elsif input == "\e[C" # right key
      editor.move_cursor :right
      #text += input
    elsif input == "\x01" # home key
      editor.move_cursor :home
      #text += "\e[D\e[D\e[D\e[D"
    elsif input == "\x05" # end key
      editor.move_cursor :end
      #text += input
    end

    selected = selected % 6

    #puts ''
    completions = ['rzer ezrzerz rzerez rezrzer ze' + input.inspect,
                   'rzer ezrzerz rzf sdfsfsderez rezrzer top: ',
                   'rzer ezrez rezrzer ze',
                   'rzerr ze',
                   'rzer ezrzerz rzerez rezrzer ze']
    completions.shuffle!
    completions.each_with_index do |c, i|
      #print "\033[2B" #down
      #$stdout.flush
      #print "\033[2B" #down
      #$stdout.flush
      puts ''
      if i + 1 == selected
        print "\e[47m"; print "\e[30m"
      end
      print c
      if i + 1 == selected
        print "\e[0m"
      end

      # erase to end of line
      print "\033[K"

      #$stdout.flush

    end
    puts ''
    print "\033[6A"
    #print "\033[u" #restore
    #$stdout.flush


  end
end

main()