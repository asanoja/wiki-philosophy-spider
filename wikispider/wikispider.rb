require 'rubygems'
require 'cgi'
require 'hpricot'
require 'open-uri'
require 'uri'

class ParA
	def to_s
		'('
	end
end

class ParC
	def to_s
		')'
	end
end

class Link
	def initialize(elem)
		@href = CGI::unescape(elem.attributes['href'].gsub("/wiki/",""))
	end
	def to_s
		@href
	end
end

def checklnk(href)
	ret = true
	["File:","Wikipedia:"].each do |x|
		if ret and href.include? x
			ret = false
		end
	end
	ret
end

print "Term: "
direccion = gets.chomp.gsub(' ','_')

if direccion.nil?
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

while cuenta<limit and !ciclo
	
	visited.push direccion.strip.downcase unless visited.include? direccion.strip.downcase
	
	ciclo = (ant3 == direccion)
	begin
		page = Hpricot( open( "https://en.wikipedia.org/wiki/#{CGI::escape(direccion)}","User-Agent" => "Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20110506 Firefox/4.0.1" )) 
	rescue
		puts "Term #{direccion} not found"
		exit
	end
	
	if debug
		print  "#{cuenta}. #{direccion.strip} <= (#{sal.join(",")}) #{ant3} "
	else
		print "#{cuenta}. #{direccion.strip} "
	end

	enlaces = []
	results = page.search( "//p" ) + page.search( "//div/ul/li" )
	results.each do |parrafo|
		p parrafo if debug
		html = parrafo.to_s
		if html!=""
			parrafo.search("a").to_a.each do |lnk|
				if lnk.attributes['href'][0..5]=="/wiki/" and checklnk(lnk.attributes['href']) and !lnk.attributes['href'].include?("#") and !lnk.attributes['title'].include?("Geographic coordinate system")
					enlaces << lnk unless lnk.nil?
				end
				p lnk if debug
			end
		end
	

		k=0
		enlaces.each do |l|
			html.gsub!(l.to_s,"~#{k}~")
			k+=1
		end
	
		if debug
			puts "="*80
			puts html
		end
	
		intro = []
		acum = ""
		flag=false
		html.each_char do |c|
			if !flag and c=='~'
				flag=true
				acum=c
			else
				if flag and c=='~'
					flag=false
					acum+=c
					intro << Link.new(enlaces[acum.gsub('~','').to_i]) unless enlaces[acum.gsub('~','').to_i].nil?
					acum=""
				else			
					if !flag
						if c=='('
							intro << ParA.new
						else
							if c==')'
								intro << ParC.new
							else
								intro << c
							end
						end
					else
						acum+=c
					end
				end
			end
		end

		intro.delete_if {|x| x.class!=Link and x.class!=ParA and x.class!=ParC}
		if debug
			puts "="*80
			puts intro.join(",")
		end
	
		p = 0
		sal = []
		intro.each do |x|
			if x.kind_of? ParA
				p+=1
			else
				if x.kind_of? ParC
					p-=1
				else
					if x.kind_of? Link and p>0
						#skip
					else
						sal << x	
					end
				end	
			end
		end
		if debug
			puts "="*80
			p sal 
			gets
		end
		break if sal!=[]
	end
	
	es_elem = page.at("//a[text() = 'Español']")
	unless es_elem.nil?
		translation = es_elem.attributes["title"].split("–")[0]
		puts " -- #{translation.strip}"
	else
		puts " -- (no translation)"
	end
	
	puts "........................Going beyond Philosophy..." if direccion=="Philosophy"

	sal.each do |link|
		direccion = link.to_s
		break unless visited.include? direccion.strip.downcase
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
	puts "#{cuenta}. #{direccion}" if direccion=="Philosophy"
end

