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
	def class
	p @href
		re = /\((\w+),(\w+)\)/
		match = re.match(@href)
		if match
		  return match[1]
		 else
		  return "NONE"
		end
	end
	def term
		return CGI::unescape(@elem.attributes['href'].gsub("/wiki/",""))
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
	
	visited.push term.strip.downcase #unless visited.include? direccion.strip.downcase
	
	ciclo = (ant3 == term)
	begin
		#~ page = Hpricot( open( "https://#{first_lang}.wikipedia.org/wiki/#{CGI::escape(term)}","User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20110506 Firefox/4.0.1" )) 
		page = Hpricot( open( "http://localhost/wiki/1.html","User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20110506 Firefox/4.0.1" )) 
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
	results = page.search( "//p" ) + page.search( "//div/ul/li" )
	results.each do |parrafo|
		html = parrafo.to_s
		unless html.empty?
			parrafo.search("a").to_a.each do |elem|
				unless elem.nil?
					lnk = Link.new(elem)
					enlaces << lnk if lnk.valid?
				end
			end
		else
			puts "empty"
		end
		puts 
		enlaces.each {|link| puts "#{link.class}::#{link.term}"}
gets
	end
	
	es_elem = page.at("//a[@lang = '#{second_lang}']")
	unless es_elem.nil?
		translation = es_elem.attributes["title"].split("–")[0]
		puts " -- #{translation.strip}"
	else
		puts " -- (no translation for #{second_lang})"
	end
	
	puts "........................Going beyond Philosophy..." if term=="Philosophy"

	sal.each do |link|
		if !visited.include?(link.to_s.strip.downcase)
			term = link.to_s
			break
		end
	end
	cuenta+=1
	ant3 = ant2
	ant2 = ant1
	ant1 = direccion

	sleep 1.5
end
if ciclo
	puts "Loop detected. stop!"
else
	puts "#{cuenta}. #{direccion}" if term=="Philosophy"
end

