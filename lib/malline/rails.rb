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

require 'malline' unless Kernel.const_defined?('Malline')

if Rails::VERSION::STRING <= "2.0.z"
	ActionView::Base.register_template_handler 'mn', Malline::Base
	module ActionView
		class Base
			alias_method :orig_render_template, :render_template
			def render_template template_extension, template, file_path = nil, *rest
				@current_tpl_path = file_path
				orig_render_template(template_extension, template, file_path, *rest)
			end
	
			alias_method :orig_delegate_render, :delegate_render
			def delegate_render(handler, template, local_assigns)
				old = @malline_is_active
				tmp = if handler == Malline::Base
					h = handler.new(self)
					h.set_path(@current_tpl_path) if @current_tpl_path
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
else
	ActionView::Template.register_template_handler 'mn', Malline::Base
end
