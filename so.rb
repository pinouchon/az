require 'rubygems'
require 'httparty'
require 'open-uri'

class StackExchange
  include HTTParty
  base_uri 'api.stackexchange.com'

  def initialize(service, page)
    @options = { :query => {:site => service, :page => page} }
  end

  def search(q)
    #self.class.get("/2.2/search/excerpts?order=desc&sort=activity&q=find%20files%20recursively&site=stackoverflow")
    self.class.get("/2.2/search/excerpts?pagesize=5&order=desc&sort=activity&body=#{q}&site=stackoverflow")
  end

  def questions
    self.class.get("/2.2/questions", @options)
  end

  def users
    self.class.get("/2.2/users", @options)
  end
end

stack_exchange = StackExchange.new("stackoverflow", 1)
#puts stack_exchange.questions
#puts stack_exchange.users

ids = []
q = URI::encode('undo git add')
stack_exchange.search(q)['items'].each do |i|
  #puts i['body'].scan(/\n\n(.*)\n\n/).join('  ==  ')
  #puts ''
  #puts ''
  ids << i['question_id'] if i['question_id']
  ids << i['answer_id'] if i['answer_id']
end
ids = ids.uniq

require './noko.rb'
commands = []
ids.each do |id|
  commands += get_post_commands(id)
end
commands = commands.uniq

puts ">>>>>>> #{commands.count} commands:"
puts commands.join("\n")

#get_post_commands