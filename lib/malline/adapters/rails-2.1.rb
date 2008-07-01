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


# We need to redefine some ActionView::Template methods, Since Rails 2.1 doesn't
# offer any better way to do some things.
class ActionView::Template
	alias_method :orig_render, :render
	# Tell Malline to be deactivated if there is a non-Malline partial inside
	# Malline template.
	def render *args, &block
		return orig_render *args, &block unless @view.respond_to? :malline_is_active
		old, @view.malline_is_active = @view.malline_is_active, false
		ret = orig_render *args, &block
		@view.malline_is_active = old
		ret
	end
end

module Malline
	# Malline template handler for Rails 2.1
	#
	# We use Compilable-interface, even though Malline templates really doesn't
	# compile into anything, but at least template files won't always be re-read
	# from files. Builder templates (.builder|.rxml) also use this interface.
	class RailsHandler < ActionView::TemplateHandler
		include ActionView::TemplateHandlers::Compilable

		# We have three lines framework code before real template code in
		# 'compiled code'
		def self.line_offset
			3
		end

		# Compiles the template, i.e. return a runnable ruby code that initializes
		# a new Malline::Base objects and renders the template.
		def compile template
			path = template.path.gsub('\\', '\\\\\\').gsub("'", "\\\\'")
			"__malline_handler = Malline::Base.new self
			malline.path = '#{path}'
			__malline_handler.render do
				#{template.source}
			end"
		end

		# Get the rendered fragment contents
		def cache_fragment block, name = {}, options = nil
			@view.fragment_for(block, name, options) do
				eval("__malline_handler.rendered", block.binding)
			end
		end
	end
end

ActionView::Template.register_template_handler 'mn', Malline::RailsHandler
