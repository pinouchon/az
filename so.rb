require 'rubygems'
require 'httparty'

class StackExchange
  include HTTParty
  base_uri 'api.stackexchange.com'

  def initialize(service, page)
    @options = { :query => {:site => service, :page => page} }
  end

  def search
    self.class.get("/2.2/search/excerpts?order=desc&sort=activity&q=find%20files%20recursively&site=stackoverflow")
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

stack_exchange.search['items'].each do |i|
  #puts i['body'].inspect
  puts i['body'].scan(/\n\n(.*)\n\n/).join('  ==  ')
  puts ''
  puts ''
end