require "wriggler/version"
require "nokogiri"
require "find"

module Wriggler
	attr_reader :content, :directory

  def self.crawl(tags=[], directory="")
    @content = Hash[tags.map {|k| [k, []]}]   #Hash with content
    @directory = directory                    #Current top-level directory

    navigate_directory
    @content
  end

  def self.navigate_directory
 		#Set the cwd to the given dir send to gather all nested files from there
 		Dir.chdir(@directory) 
 		gather_files
  end

  def self.gather_files
  	#Gathers all of the HTML or XML files from this and all subdirectories into an array
    Find.find(@directory) do |file|
      if is_XML?(file) || is_HTML?(file)
        open_next_file(file)
      end
    end
  end

  def self.open_next_file(file)
  	#Opens the next file on the list, depending on the extension passes it to HTML or XML
  	f = File.open(file)

  	if is_HTML?(file)
  		set_HTML(f)
  	elsif is_XML?(file)
  		set_XML(f)
  	end
  end

  def self.is_HTML?(file)
  	#Determines, using a regex check, if it is an HTML file
  	file =~ /.html/
  end

  def self.is_XML?(file)
  	#Determines, using a regex check, if it is an XML file
  	file =~ /.xml/
  end

  def self.set_HTML(file)
  	#Set the HTML file into Nokogiri for crawling
  	doc = Nokogiri::HTML(file)
  	crawl_file(doc)
  end

  def self.set_XML(file)
  	#Set the XML file into Nokogiri for crawling
  	doc = Nokogiri::XML(file)
  	crawl_file(doc)
  end

  def self.crawl_file(doc)
    #Crawl the Nokogiri Object for the file
    @content.each_key do |key|
      arr = []
      if !doc.xpath("//#{key}").empty?        #Returns an empty array if tag is not present
        doc.xpath("//#{key}").map{ |tag| arr << sanitize(tag.text) }
      else
        doc.xpath("//#{key}").map{ |_| arr << "" }
      end
      @content.fetch(key) << arr
    end
  end

  def self.sanitize(text)
  	#Removes any escaped quotes, replaces them
  	text.gsub(/"/, "'").lstrip.chomp				
  end

end
