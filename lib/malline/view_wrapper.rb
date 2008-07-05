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
	# ViewWrapper is extended into used view object, like ActiveView::Base.
	# Every method in ViewWrapper will pollute the original namespace.
	module ViewWrapper
		# List of all methods that may override some custom view methods
		# If is_malline?, then their _malline_ -prefix versions are called
		@@malline_methods = %w{_erbout capture _ tag! << txt!}

		# Initialize @@malline_methods
		def init_malline_methods
			@malline_methods_inited = true
			@@malline_methods.each do |m|
				mf = m.gsub('<', 'lt')
				eval %{def #{m}(*x, &b) is_malline? ? _malline_#{mf}(*x, &b) : super; end}
			end
		end

		# Returns a current Template instance, makes a new if called first time
		# Can also be used to set options to Template by giving them as hash opts:
		# 	malline :whitespace => true
		def malline opts = nil
			if @malline
				@malline.options.merge!(opts) if opts.is_a?(Hash)
			else
				@malline = Template.new(self, opts || {})
			end
			init_malline_methods unless @malline_methods_inited
			@malline
		end
		
		# erbout emulator
		def _malline__erbout
			@_erbout ||= ErbOut.new(self)
		end

		# capture and return the output of the block
		def _malline_capture &block
			@malline.run &block
		end

		# _'escaped text'
		def _malline__ *args
			@malline.add_text(*args)
		end
		alias_method :_malline_txt!, :_malline__

		# self << "<unescaped text>"
		def _malline_ltlt *args
			@malline.add_unescaped_text *args
		end

		# Define a new tag of call a helper (if _prefixed)
		def method_missing s, *args, &block
			return super unless is_malline?
			if @malline.tags[s]
				@malline.tag s, *args, &block
			else
				helper = ((s.to_s[0] == ?_) ? s.to_s[1..-1] : s).to_sym
				if respond_to?(helper)
					@malline.helper(helper, *args, &block)
				else
					return super if @malline.options[:strict]
					_malline_tag! s, *args, &block
				end
			end
		end

		# Define a new tag
		def _malline_tag! *args, &block
			@malline.tag *args, &block
		end

		# Are we in a Malline template
		def is_malline?
			true
		end
	end
end
