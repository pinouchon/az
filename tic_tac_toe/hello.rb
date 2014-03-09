#!/usr/local/bin/ruby

t = Thread.start{
  begin
    puts "starting executing code!"
    sleep 1
    puts "done executing code!" # we don't expect to reach here
  rescue Exception
    puts "rescuing!"            # we don't expect to reach here
  ensure
    sleep(0.5)
    puts "ensuring!"            # will we reach here????? (yes)
  end
}
t.kill
t.join
puts "done!"
abort()