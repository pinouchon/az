require 'readline'
require '../noko.rb'

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

class Shell
  attr_accessor :prompt, :position, :buffer

  KEY_TOP = "\e[A"
  KEY_RIGHT = "\e[C"
  KEY_DOWN = "\e[B"
  KEY_LEFT = "\e[D"
  KEY_BACKSPACE = "\x7F"
  KEY_ENTER = "\r"
  KEY_CTRL_C = "\x03"
  KEY_TAB = "\t"

  SEQ_ERASE_LEFT = "\e[D"
  SEQ_ERASE_TO_END_OF_LINE = "\033[K"

  def initialize
    @prompt = '$> '
    @position = 0
    @buffer = ''
    @line_selected = 0
    @history = File.read(ENV['HOME']+'/.zsh_history').
        force_encoding('iso-8859-1').split("\n").map do |line|
      line[/: [0-9]+:0;(.*)/, 1]
    end
    @width = `/usr/bin/env tput cols`.to_i
    @completions = []

    print @prompt
  end

  def special_actions
    {
        KEY_TOP => -> {
          @line_selected -= 1
          @line_selected %= 11
        },
        KEY_RIGHT => -> {
          @position = [@buffer.length, @position + 1].min
        },
        KEY_DOWN => -> {
          @line_selected += 1
          @line_selected %= 11
        },
        KEY_LEFT => -> {
          @position = [0, @position - 1].max
        },
        KEY_BACKSPACE => -> {
          @buffer = @buffer[0..-2]
          @position = @buffer.length
        },
        KEY_ENTER => -> {
          if @line_selected == 0
            system(@buffer)
            exit
          else
            @buffer = find_completions(@buffer)[@line_selected - 1]
            @position = @buffer.length
            @line_selected = 0
          end
        },
        KEY_CTRL_C => -> {
          exit
        },
        KEY_TAB => -> {
          find_so_completions
        }
    }
  end

  def find_so_completions
    q = URI::encode("#{@buffer} stackoverflow")
    @completions = google_search(q)[0, 10]
  end

  def find_completions(str)
    @completions = @history.select do |h|
      h && h.include?(str)
    end.compact.uniq[0,10] || []
  end

  def print_completions
    @completions.fill(nil, @completions.length...10).each_with_index do |c, i|
      puts ''
      print "\e[47m" + "\e[30m" if i + 1 == @line_selected
      print c[0..@width - 1] if c
      print "\e[0m" if i + 1 == @line_selected
      print "\033[K"
    end
    puts "\033[K"
    print "\033[11A"
  end

  def redraw
    print_completions
    print SEQ_ERASE_LEFT * (@buffer.length + @prompt.length + 1)
    print SEQ_ERASE_TO_END_OF_LINE
    print @prompt + @buffer
    print SEQ_ERASE_LEFT * (@buffer.length - @position)
  end

  def handle_key(k)
    if special_actions[k]
      special_actions[k].call
    else
      @buffer.insert(@position, k)
      @position += 1
      find_completions(@buffer)
    end
    redraw
  end
end

def main
  shell = Shell.new
  while true do
    shell.handle_key(read_char())
  end
end

main