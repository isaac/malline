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
	class ViewProxy
		def initialize template, tag
			@tpl = template
			@tag = tag
		end

		def __yld &block
			@tpl.execute @tag[:children], &block
		end

		def method_missing(s, *args, &block)
			if args.last.is_a?(Hash)
				@tag[:attrs].merge!(args.pop)
			end

			if /\!$/ =~ s.to_s
				@tag[:attrs]['id'] = s.to_s.chomp('!')
			else
				if @tag[:attrs]['class']
					@tag[:attrs]['class'] << " #{s}"
				else
					@tag[:attrs]['class'] = s.to_s
				end
			end

			whitespace = @tpl.whitespace
			@tpl.whitespace = true if args.delete(:whitespace)
			txt = args.flatten.join('')
			@tag[:children] << txt unless txt.empty?

			@tpl.execute @tag[:children], &block if block_given?
			@tpl.whitespace = whitespace
			self
		end
	end
end
