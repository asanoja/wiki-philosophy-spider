require 'rubygems'
require 'cgi'
require 'hpricot'
require 'open-uri'
require 'uri'

class Link
	def initialize(elem)
		@elem = elem
		@href=elem.attributes['href']
	end
	def wiki_class
		match = ""
		@href.sub(/(\(.*?\))/) { match = $1 }
		if match
		  return match.gsub("(","").gsub(")","").upcase
		else
		  return nil
		end
	end
	def term
		return CGI::unescape(URI.parse(@href).path).gsub("/wiki/","").gsub("_(#{wiki_class.downcase})","").strip
	end
	def name
		if wiki_class.nil? || wiki_class.empty?
			return "#{term}"
		else
			return "#{wiki_class}::#{term}"
		end
	end
	def valid?
		ret = true
		["File:","Wikipedia:","Glossary_of","List_of","Geographic_coordinate_system",":","#"].each do |x|
			if ret and term.include?(x) and term.start_with?("/wiki/")
				return false
			end
		end
		return true
	end
	def to_s
		term
	end
end



print "Term: "
term = gets.chomp.gsub(' ','_').strip

if term.nil?
	puts "Must enter a term"
	exit
end

cuenta = 1
debug = false
ciclo = false
ant1 = ant2 = ant3 = html = ""
sal = []
enlaces = []
visited = []
limit=50
first_lang="en"
second_lang="es"

while cuenta<limit and !ciclo
	
	visited.push term.downcase
	
	ciclo = (ant3 == term)
	begin
		#~ page = Hpricot( open( "https://#{first_lang}.wikipedia.org/wiki/#{CGI::escape(term)}","User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20110506 Firefox/4.0.1" )) 
		page = Hpricot( open( "http://192.168.1.200/wiki/1.html","User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20110506 Firefox/4.0.1" )) 
	rescue
		puts "Term #{term} could not be fetch"
		exit
	end
	
	if debug
		print  "#{cuenta}. #{term} <= (#{sal.join(",")}) #{ant3} "
	else
		print "#{cuenta}. #{term} ".ljust(30)
	end

	enlaces = []
	results = page.search( "//div[@class='mw-parser-output']//p" ) + page.search( "//div/ul/li" )
	results.each do |parrafo|
		html = parrafo.to_s
		unless html.empty?
			parrafo.search("a").to_a.each do |elem|
				unless elem.nil?
					lnk = Link.new(elem)
					puts "ADD #{lnk.name} #{elem.xpath}"
					gets
					enlaces << lnk if lnk.valid?
				end
			end
		else
			puts "empty"
		end
	end
	
	es_elem = page.at("//a[@lang = '#{second_lang}']")
	unless es_elem.nil?
		translation = es_elem.attributes["title"].split("–")[0]
		puts " -- #{translation.strip}"
	else
		puts " -- (no translation for #{second_lang})"
	end
	
	puts "........................Going beyond Philosophy..." if term=="Philosophy"

	#~ p visited
	enlaces.each {|lnk| puts lnk.wiki_class}
	gets
	enlaces.each do |link|
		puts link.name
		if !visited.include?(link.name)
			term = link.to_s
			break
		end
	end
	cuenta+=1
	ant3 = ant2
	ant2 = ant1
	ant1 = term

	sleep 1.5
end
if ciclo
	puts "Loop detected. stop!"
else
	puts "#{cuenta}. #{direccion}" if term=="Philosophy"
end

