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

module Malline
	class FormBuilder
		def initialize *args
			@view = eval('self', args.last)
			@view = nil unless @view.respond_to?(:is_malline?) && @view.is_malline?
			@builder = ::ActionView::Helpers::FormBuilder.new(*args)
		end
		def method_missing *args, &block
			if @view
				@view << @builder.send(*args, &block)
			else
				@builder.send(*args, &block)
			end
		end
	end
end
