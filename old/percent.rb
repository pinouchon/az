#!/usr/bin/env ruby

require 'curses'

Curses.noecho
Curses.init_screen

class Worker
  def initialize(index)
    @index = index
    @percent = 0
  end

  def run
    (1..10).each do
      work
      report
      sleep(rand())
    end
  end

  def to_s
    "Worker ##{'%2d' % @index} is #{'%3d' % @percent}% complete"
  end

  private

  def work
    @percent += 10
  end

  def report
    Curses.setpos(@index, 0)
    Curses.addstr(to_s)
    Curses.refresh
  end
end

workers = (1..10).map{ |index| Worker.new(index) }

at_exit do
  workers.each{ |worker| puts worker }
end

workers.map{ |worker| Thread.new{ worker.run } }.each(&:join)

Curses.close_screen