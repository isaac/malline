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

ActionView::Base.register_template_handler 'rb', Malline::Base
module ActionView
	# We need to redefine some ActionView::Base methods, Since Rails 2.0 doesn't
	# offer any better way to do some things.
	class Base
		alias_method :orig_render_template, :render_template
		# We want to save the name of the current file to @current_tpl_path,
		# because then the error backtrace from Rails will include the
		# name of the file. I didn't find better way to get this
		def render_template template_extension, template, file_path = nil, *rest
			@current_tpl_path = file_path
			orig_render_template(template_extension, template, file_path, *rest)
		end

		alias_method :orig_compile_and_render_template, :compile_and_render_template
		def compile_and_render_template handler, *rest
			if self.respond_to? :is_malline?
				old, @malline_is_active = is_malline?, false
				output = orig_compile_and_render_template handler, *rest
				@malline_is_active = old
				output
			else
				@malline_is_active = false
				orig_compile_and_render_template handler, *rest
			end
		end

		alias_method :orig_delegate_render, :delegate_render
		# Update the current file to malline and tell Malline to be deactivated
		# if there is a non-Malline partial inside Malline template.
		def delegate_render(handler, template, local_assigns)
			old = is_malline?
			tmp = if handler == Malline::Base
				h = handler.new(self)
				h.path = @current_tpl_path if @current_tpl_path
				@malline_is_active = true
				h.render(template, local_assigns)
			else
				@malline_is_active = false
				orig_delegate_render(handler, template, local_assigns)
			end
			@malline_is_active = old
			tmp
		end
	end
end

module Malline::ViewWrapper
	# Activate Malline if we are not using ActionView::Base or if
	# the current template is a Malline template
	def is_malline?
		@malline_is_active.nil? ? true : @malline_is_active
	end
end

