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
	class Template
		attr_accessor :options
		attr_accessor :short_tag_excludes
		attr_accessor :whitespace
		attr_accessor :path

		def initialize view, opts
			@view = view
			@whitespace = false
			@path = 'Malline template'
			@options = opts
			@short_tag_excludes = []
		end

		# These two are stolen from ERB
		# © 1999-2000,2002,2003 Masatoshi SEKI
		def self.html_escape(s)
			s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;")
		end
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

		def add_text *values
			@dom << ' ' if @whitespace
			@dom << Template.html_escape(values.join(' '))
		end

		def add_unescaped_text value
			@dom << ' ' if @whitespace
			@dom << value.to_s unless value.nil?
		end

		def helper helper, *args, &block
			tmp = @view.send(helper, *args, &block)
			@dom << ' ' if @whitespace
			@dom << tmp.to_s
			tmp
		end

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

		# Render the xml tree at dom or root
		def render dom = nil
			(dom || @dom).inject('') do |out, tag|
				if tag.is_a?(String)
					out << tag
				else
					out << ' ' if tag[:whitespace]
					out << "<#{tag[:name]}"
					out << tag[:attrs].inject(''){|s, a| s += " #{a.first}=\"#{Template.html_escape(a.last)}\""}

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
			tmp = []
			execute tmp, tpl, &block
			render tmp
		end
	end
end
