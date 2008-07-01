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
	# Every tag returns a ViewProxy object that binds the tag to the template.
	# ViewProxy also chains the process by returning itself.
	#
	# This Proxy object then makes possible the attribute syntax:
	# 	div.foo.bar! { stuff }
	#
	# div returns new ViewProxy instance, so div.foo actually calls
	# ViewProxy#foo, which is then generated to class="foo" -attribute to the
	# original tag div. div.foo returns the same ViewProxy, and foo.bar! calls
	# ViewProxy#bar!, which is interpreted as a id="bar" -attribute.
	#
	# Finally the given block { stuff } is evaluated the same way than it would
	# be evaluated without the ViewProxy:
	#   div { stuff }
	class ViewProxy
		def initialize template, tag
			@tpl = template
			@tag = tag
		end

		# Allows to add new content to already closed tag, for example:
		# 	t = div do
		# 		_'text'
		# 	end
		# 	t.__yld :whitespace { stuff }
		#
		# Intended for internal use only
		def __yld *args, &block
			# div :title => 'data'
			if args.last.is_a?(Hash)
				@tag[:attrs].merge!(args.pop)
			end

			# Modifiers
			whitespace = @tpl.whitespace
			@tpl.whitespace = true if args.delete(:whitespace)

			# Rest is just content separated by a space
			txt = args.flatten.join ' '
			@tag[:children] << txt unless txt.empty?

			# Block
			@tpl.execute @tag[:children], &block if block_given?

			# Restore modifiers
			@tpl.whitespace = whitespace

			# Chain the calls, for example: div.foo.bar!.yeah.boring
			self
		end

		# Capture attribute definitions, special modifiers and blocks
		def method_missing s, *args, &block
			# div.id!
			if /^(.*)!$/ =~ s.to_s
				@tag[:attrs]['id'] = $1
			elsif s
				# div.class
				if @tag[:attrs]['class']
					@tag[:attrs]['class'] << " #{s}"
				else
					@tag[:attrs]['class'] = s.to_s
				end
			end

			__yld *args, &block
		end
	end
end
