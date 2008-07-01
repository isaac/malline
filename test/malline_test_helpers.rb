# Copyright © 2007,2008 Riku Palomäki
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
require 'malline.rb'

module MallineTestHelpers
	include REXML
	Image = Struct.new "Image", :id, :url, :caption
	def assert_xml_equal a, b, c=""
		if convert(Document.new(a)) != convert(Document.new(b))
			assert_equal a, b, c
		else
			assert true
		end
	rescue
		assert_equal a, b, c
	end
	def attributes element
		element.attributes.keys.sort.collect {|k| " #{k}=\"#{element.attributes[k]}\""}.join
	end
	# quick hack to compare two html files
	def convert e
		output = ''
		if e.is_a?(Array)
			e.each {|el| output << convert(el) }
		elsif e.respond_to?(:children) or e.is_a?(Element)
			output << "<#{e.name}"
			output << attributes(e) if e.respond_to?(:has_attributes?) and e.has_attributes?
			output << ">"
			e.children.each {|el| output << convert(el) } unless e.children.empty?
			output << "</#{e.name}>"
		else
			output << e.to_s
		end
		output
	end
end

class Controller
	def perform_caching
		false
	end
end

class Comment
end

class View
	def initialize
		@controller = Controller.new
	end
	def image_path(im)
		"/images/#{im.is_a?(MallineTestHelpers::Image) ? im.id : 'img'}"
	end
	def truncate(str, size = 10)
		str[0...size]
	end
	def render hash
		Malline::Base.new(View.new).render File.read(File.join(File.dirname(__FILE__), hash[:partial].sub(/\//, '/_') + '.mn')) rescue ''
	end
	def link_to *args
		'link'
	end
	def zoo *args
		'zoo output'
	end
end
