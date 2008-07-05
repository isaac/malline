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
	# Capture form elements directly from FormBuilder, so that there is no
	# need to specially render any elements.
	# In other words, with our own FormBuilder-wrapper we can do this:
	# 	form_for :comment, Comment.new, :url => edit_url do |f|
	# 		f.text_field :name
	# 	end
	# instead of
	# 	..
	# 	self << f.text_field(:name)
	class FormBuilder
		# Wrap the Rails FormBuilder in @builder
		def initialize *args, &block
			@view = eval('self', args.last)
			@builder = ::ActionView::Helpers::FormBuilder.new(*args, &block)
		end
		# Render every f.foo -method to view, unless we aren't using
		# Malline template now
		def method_missing *args, &block
			if @view && @view.is_malline?
				@view << @builder.send(*args, &block)
			else
				@builder.send(*args, &block)
			end
		end
	end
end
