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
require 'malline/form_builder.rb'

if Rails::VERSION::STRING <= "2.0.z"
	require 'malline/adapters/rails-2.0'
else
	require 'malline/adapters/rails-2.1'
end

# Activate our FormBuilder wrapper, so we can use forms more easily
ActionView::Base.default_form_builder = Malline::FormBuilder

module Malline::ViewWrapper
	@@malline_methods << 'cache'

	# Rails caching
	def _malline_cache name = {}, options = {}, &block
		return block.call unless @controller.perform_caching
		cache = @controller.read_fragment(name, options)

		unless cache
			cache = _malline_capture { block.call }
			@controller.write_fragment(name, cache, options)
		end
		@malline.add_unescaped_text cache
	end
end


