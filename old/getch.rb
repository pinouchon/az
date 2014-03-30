
#!/usr/bin/ruby
# getch 1.0b
# H Gabriel Maculus - Sun Jan 17 2010
# Inpired from code by Alec Jacobson
# License: BSD

def get_ch
  save = %x/stty --save/
  %x/stty raw -echo /
  a = STDIN.getc
  case a
    when 27 # First special key
      puts "[27]\r"
      e = STDIN.getc
      case e
        when 79 # Second Special key
          puts "[79]\r"
          puts STDIN.getc.to_s
        when 91 # Second Special key
          puts "[91]\r"
          n = STDIN.getc
          case n
            when 49 # Third Special key
              puts "[49]\r"
              puts STDIN.getc.to_s
            else
              puts n.to_s
          end
      end
    else
      puts a.to_s + "\r"
  end
  %x/stty #{save}/
  return a
end

get_ch