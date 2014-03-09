require 'io/console'

KEY_BACKSPACE = "\x7F"
KEY_HOME = "\x01"
KEY_END = "\x05"
KEY_LEFT = "\e[D"
KEY_RIGHT = "\e[C"
KEY_UP = "\e[A"
KEY_DOWN = "\e[B"
ERASE_TO_END_OF_LINE = "\033[K"

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

def init
  #print "$> "
end

def main
  saved = false
  init()

  text = ''
  selected = 0
  top = false
  1000.times do
    print "\033[K"
    print "$> " + text

    input =  STDIN.getch
    check_break_commands(input)

    #abort("=" + input + "=")
    if input == KEY_BACKSPACE
      text = text[0..-2]
      #puts text
      #puts text[0..-1]
      #text += "====="
    elsif ('a'..'z').include?(input)# || ('A'..'Z').include?(input)
      text += input
    elsif input == KEY_HOME
      abort('home')
    elsif input == KEY_END
      abort('end')
    elsif input == ['D'].include?(input)
      abort('D')
    else
      abort('===>' + input + '<===')
    end

    if input == "\e[A"
      top = true
    else
      top = false
    end


    #print "\033[10B"
    #print "completions: ..."
    #print "\033[10A"

    #print "\033[u" if saved
    #print "\033[s" if !saved
    saved = true

    #puts ''
    completions = ['rzer ezrzerz rzerez rezrzer ze' + input.inspect,
                   'rzer ezrzerz rzf sdfsfsderez rezrzer top: ' + top.inspect,
                   'rzer ezrez rezrzer ze',
                   'rzerr ze',
                   'rzer ezrzerz rzerez rezrzer ze']
    completions.shuffle!
    completions.each do |c|
      #print "\033[2B" #down
      #$stdout.flush
      #print "\033[2B" #down
      #$stdout.flush
      puts ''
      print c
      print ERASE_TO_END_OF_LINE

      #$stdout.flush

    end
    puts ''
    # move up N lines
    print "\033[6A"

    #print "\033[u" #restore
    #$stdout.flush


  end
end

main()

#puts text.inspect


#puts "\e[0m\e[30;47mHello!\e[0m"
#
#
#puts "-----------------"
#puts "-----------------"
#puts "-----------------"
#puts "-----------------"
#puts "-----------------"
#puts "-----------------"
#puts "\033[6B"
#puts "O"
#
#puts "\033[6A"
#puts "=="
#puts "\033[K"
