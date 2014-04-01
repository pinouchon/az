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
  KEY_TOP = "\e[A"
  KEY_RIGHT = "\e[C"
  KEY_DOWN = "\e[B"
  KEY_LEFT = "\e[D"
  KEY_BACKSPACE = "\x7F"
  KEY_ENTER = "\r"
  KEY_CTRL_C = "\x03"

  attr_accessor :prompt, :buffer, :position

  def initialize
    @prompt = '$> '
    @buffer = ''
    @position = 0

    print @prompt
  end

  def actions
    {
        KEY_TOP => -> {
          puts 'top'
        },
        KEY_DOWN => -> {
          puts 'down'
        },
        KEY_BACKSPACE => -> {
          @buffer = @buffer[0..-2]
          @position = @buffer.length
        },
        KEY_RIGHT => -> {
          @position = [@buffer.length, @position + 1].min
        },
        KEY_LEFT => -> {
          @position = [0, @position - 1].max
        },
        KEY_CTRL_C => -> {
          exit
        },
        KEY_CTRL_C => -> {
          exit
        },
    }
  end

  def handle_char(char)
    if actions()[char]
      actions[char].call
    else
      @buffer.insert(@position, char)
      @position += 1
    end
    print "\e[D" * (@buffer.length + @prompt.length + 1)
    print "\033[K"
    print @prompt + @buffer
    print "\e[D" * (@buffer.length - @position)
  end
end

def main
  shell = Shell.new
  while true do
    shell.handle_char(read_char())
  end
end

main
