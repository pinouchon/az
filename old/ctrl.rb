require 'curses'


win = Curses::Window.new(0, 0, 0, 0)

Curses.init_screen
Curses.cbreak
Curses.nonl
Curses.stdscr.keypad(true)

loop do
  case Curses.getch
    when 13 # Enter
      Curses.addstr "abc"
    when 8 # Backspace
      Curses.delch
  end
end

win.close