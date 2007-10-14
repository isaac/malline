#!/usr/bin/env ruby
# Copyright © 2007 Riku Palomäki
#
# This file is part of Malline.
#
# Malline is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Malline is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Malline.  If not, see <http://www.gnu.org/licenses/>.

require "rexml/document"
include REXML

def html_unescape str
	str.to_s.gsub('&amp;', '&').gsub('&quot;', '"').gsub('&gt;', '>').gsub('&lt;', '<')
end

def esc str
	if str =~ /["#]/ || !(str =~ /'/)
		"'"+(str.split("'").join("\\'"))+"'"
	else
		"\"#{str}\""
	end
end

def attributes element
	element.attributes.keys.collect {|k| "#{esc k} => #{esc html_unescape(element.attributes[k])}" }.join(', ')
end

def txtize txt
	#txt.gsub(/(\s)\s*$/, '\1').gsub(/^(\s)\s*/, '\1')
	txt.gsub(/\s*$/, '').gsub(/^\s*/, '')
end

def convert element, prefix=''
	valid_method = /^[A-Za-z][\w_]*$/
	output = ''
	if element.is_a?(Array)
		element.each {|e| output << convert(e) }
	elsif element.is_a?(Element)
		output << prefix << element.name
		attrs = []
		element.attributes['class'].to_s.split.uniq.each do |cl|
			if valid_method =~ cl
				output << ".#{cl}"
			else
				attrs << cl
			end
		end
		element.attributes.delete('class')
		element.attributes['class'] = attrs.join(' ') unless attrs.empty?
		if element.attributes['id'].to_s =~ valid_method
			output << ".#{element.attributes['id']}!"
			element.attributes.delete('id')
		end
		txt = ''
		children = element.children
		unless children.empty?
			if children.first.is_a?(Text)
				txt = txtize children.shift.to_s
				output << " #{esc html_unescape(txt)}" unless txt.empty?
			end
		end

		output << (txt.empty? ? ' ' : ', ') << attributes(element) if element.has_attributes?
		unless children.empty?
			output << " do\n"
			children.each {|e| output << convert(e, prefix + "\t") }
			output << prefix << "end"
		end
		output << "\n"
	elsif element.is_a?(Text)
		txt = txtize(element.to_s)
		output << prefix << "txt! #{esc html_unescape(txt)}\n" unless txt.empty?
	end
	output
end

input = File.open(ARGV.shift, 'r') rescue $stdin
output = File.open(ARGV.shift, 'w') rescue $stdout

doc = Document.new input


output.puts convert(doc.children)
