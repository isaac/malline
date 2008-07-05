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

module Malline
	# This is the class that really evaluates the template and is accessible
	# from the view by "malline", for example:
	# 	malline.path = 'File name'
	class Template
		# Current options (like @@options in Base)
		attr_accessor :options
		# List of every tag that doesn't support self-closing syntax
		attr_accessor :short_tag_excludes
		# Current state of :whitespace-modifier (bool)
		attr_accessor :whitespace
		# Current file name
		attr_accessor :path
		# Every overriden (in definetags!) helper method (:name => method)
		attr_accessor :helper_overrides
		# Every available tag, excluding the specific methods (:name => bool)
		attr_accessor :tags
		# Render result of the last #render
		attr_reader :rendered
		# List all installed plugins
		attr_accessor :plugins

		def initialize view, opts
			@view = view
			@whitespace = false
			@path = 'Malline template'
			@options = opts
			@short_tag_excludes = []
			@helper_overrides = {}
			@tags = {}
			@plugins = []
			@inited = false
		end

		# Install plugins and do every thing that cannot be done in initialize
		# Plugin install will use @view.malline, that will create a duplicate
		# Template instance, if it's called from initialize.
		def init
			return if @inited
			XHTML.install @view if @options[:xhtml]
		end

		# Stolen from ERB, © 1999-2000,2002,2003 Masatoshi SEKI
		def self.html_escape(s)
			s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
		end
		# Stolen from ERB, © 1999-2000,2002,2003 Masatoshi SEKI
		def self.url_encode(s)
			s.to_s.gsub(/[^a-zA-Z0-9_\-.]/n){ sprintf("%%%02X", $&.unpack("C")[0]) }
		end

		# Changes dom to active @dom, and executes tpl / block
		def execute dom, tpl = nil, &block
			tmp = @dom
			@dom = dom
			if block_given?
				@view.instance_eval &block
			else
				@view.instance_eval tpl, @path
			end
			@dom = tmp
		end

		# Add escaped string to @dom
		def add_text *values
			@dom << ' ' if @whitespace
			@dom << Template.html_escape(values.join(' '))
		end

		# Add unescaped string to @dom
		def add_unescaped_text value
			@dom << ' ' if @whitespace
			@dom << value.to_s unless value.nil?
		end

		# Call a helper (a method defined outside malline whose
		# output is stored to @dom)
		def helper helper, *args, &block
			helper = helper.to_sym
			tmp = if h = @helper_overrides[helper]
				h.call *args, &block
			else
				@view.send helper, *args, &block
			end
			@dom << ' ' if @whitespace
			@dom << tmp.to_s
			tmp
		end

		# Add a tag to @dom
		def tag s, *args, &block
			tag = { :name => s.to_s, :attrs => {}, :children => [] }

			tag[:whitespace] = true if @whitespace
			whitespace = @whitespace
			@whitespace = true if args.delete(:whitespace)

			if args.last.is_a?(Hash)
				tag[:attrs].merge!(args.pop)
			end

			txt = args.flatten.join('')
			tag[:children] << Template.html_escape(txt) unless txt.empty?

			@dom << tag
			execute tag[:children], &block if block_given?
			@whitespace = whitespace

			ViewProxy.new self, tag
		end

		# Render the XML tree at dom or @dom
		def render dom = nil
			@rendered = (dom || @dom).inject('') do |out, tag|
				if tag.is_a?(String)
					out << tag
				else
					out << ' ' if tag[:whitespace]
					out << "<#{tag[:name]}"
					out << tag[:attrs].inject(''){|s, a| s + " #{a.first}=\"#{Template.html_escape(a.last)}\""}

					if tag[:children].empty?
						if @short_tag_excludes.include?(tag[:name])
							out << "></#{tag[:name]}>"
						else
							out << '/>'
						end
					else
						out << '>'
						out << render(tag[:children])
						out << "</#{tag[:name]}>"
					end
				end
			end
		end

		# Execute and render a text or block
		def run tpl = nil, &block
			init
			tmp = []
			execute tmp, tpl, &block
			render tmp
		end

		# Define tags as a methods, overriding all same named methods
		def definetags! *tags
			tags.flatten.each do |tag|
				tag = tag.to_sym
				@helper_overrides[tag] = @view.method(tag) if @view.respond_to?(tag)
				define_tag! tag
			end
		end

		# Marking tags as usable, but not overriding anything
		def definetags *tags
			tags.flatten.each{|tag| @tags[tag] = true }
		end

		# Define a method tag
		def define_tag! tag
			eval %{
				def @view.#{tag}(*args, &block)
					tag!('#{tag}', *args, &block)
				end
			}
		end
	end
end
