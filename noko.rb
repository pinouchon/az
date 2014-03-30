require 'nokogiri'
require 'open-uri'

#22733049
def get_post_commands(id)
  doc = Nokogiri::HTML(open("http://stackoverflow.com/posts/#{id}/edit-inline"))
  doc.css('textarea.wmd-input').each do |post|
    return post.content.scan(/    (.*)/) + post.content.scan(/`([^`]*)`/)
  end
  []
end

def google_search(q)
  doc = Nokogiri::HTML(open("http://www.google.com/search?q=#{q}"))
  hrefs = []
  doc.css('h3.r a').each do |link|
    #puts link.content
    hrefs << link['href'] if link['href']
  end
  #hrefs.map do |h|
  #  h[/stackoverflow.com\/questions\/([0-9]+)\//, 1]
  #end

  clean_hrefs = hrefs.map do |h|
    h[/(http:\/\/stackoverflow.com\/questions\/[^&]+)/, 1]
  end.uniq.compact

  results = []
  clean_hrefs[0,2].each do |clean_href|

    doc1 = Nokogiri::HTML(open(clean_href))
    doc1.css('pre').each do |pre|
      results += pre.content
      #puts '====================================================================='
    end
  end

  return results.sort_by(&:length)
end


raw_q = 'tar unzip'
q = URI::encode("#{raw_q} stackoverflow")
puts google_search(q).join("\n")
#puts get_post_commands(6987123).join("\n")