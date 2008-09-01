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

module Malline::ViewWrapper
	# Activate Malline if we are not using ActionView::Base or if
	# the current template is a Malline template
	def is_malline?
		!(is_a?(ActionView::Base) && ActionView::Template.handler_class_for_extension(
				current_render_extension) != Malline::RailsHandler)
	end
end

# Rails has a bug with current_render_extension, lets fix it
if ActionView.const_defined?('Renderer')
	module ActionView::Renderer
		alias_method :orig_render, :render
		def render *args
			out = orig_render *args
			@view.current_render_extension = @prev_extension 
			out
		end

		alias_method :orig_prepare!, :prepare!
		def prepare! *args
			@prev_extension = @view.current_render_extension
			orig_prepare! *args
		end
	end
else
	class ActionView::Template
		alias_method :orig_render, :render
		def render *args
			out = orig_render *args
			@view.current_render_extension = @prev_extension
			out
		end

		alias_method :orig_prepare!, :prepare!
		def prepare! *args
			@prev_extension = @view.current_render_extension
			orig_prepare! *args
		end
	end
	class ActionView::PartialTemplate
		alias_method :orig_render, :render
		def render *args
			out = orig_render *args
			@view.current_render_extension = @prev_extension
			out
		end
	end
end

ActionView::Template.register_template_handler 'rb', Malline::RailsHandler
