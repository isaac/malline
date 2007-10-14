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
	module ViewWrapper
		def malline opts = nil
			if @malline
				@malline.options.merge!(opts) if opts.is_a?(Hash)
			else
				@malline = Template.new(self, opts)
			end
			@malline
		end
		
		def _erbout
			@_erbout ||= ErbOut.new(self)
			@_erbout
		end

		def cache name = {}, options = {}, &block
			return block.call unless @controller.perform_caching
			cache = @controller.read_fragment(name, options)

			unless cache
				cache = capture { block.call }
				@controller.write_fragment(name, cache, options)
			end
			@malline.add_unescaped_text cache
		end

		def capture &block
			@malline.run &block
		end

		def _ *args
			@malline.add_text(*args)
		end
		alias_method :txt!, :_

		def << *args
			@malline.add_unescaped_text *args
		end

		def method_missing s, *args, &block
			helper = (s.to_s[0].chr == '_') ? s.to_s[1..255].to_sym : s.to_sym
			if respond_to?(helper)
				@malline.helper(helper, *args, &block)
			else
				return super if @malline.options[:strict]
				tag! s, *args, &block
			end
		end

		def tag! *args, &block
			@malline.tag *args, &block
		end

		def is_malline?
			@malline_is_active
		end
	end
end
